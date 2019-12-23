//
//  MBCatchErrorLog.m
//  CatchErrorLog抓取奔溃信息
//
//  Created by yintr on 2019/12/16.
//  Copyright © 2019 Mac. All rights reserved.
//

#import "MBCatchErrorLog.h"
#import "DeviceHelper.h"
#define LOGFilePath [@"Errorlog.txt" byAppendToCacheDocument]


@implementation MBCatchErrorLog



+ (void)startCatchWithAppKey:(NSString *)appKey WithUserInfo:(NSString *)userInfo{
    if ([appKey length] <= 0){return;}
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);

    [MBCatchErrorLog printErrorLog];
    
    //存在文件就上传至服务器后删除本地文件。
    if ([MBCatchErrorLog isFileExists]){
        [MBCatchErrorLog uploadServiceWithAppKey:appKey WithUserInfo:userInfo :^(NSString *response) {
            
            //del----删除本地现有日志文件。
            [MBCatchErrorLog delErrorLogFile];
            
        }];
    }
}

+  (void)uploadServiceWithAppKey:(NSString *)appKey WithUserInfo:(NSString *) userInfo:(void (^)(NSString* response)) block{
    if ([userInfo length] <= 0) {return;}
    //Upload
    NSURL *url = [NSURL URLWithString:@"http://192.168.1.60:8089/appErrorLog/save"];//URL地址//https://api.dolry.cn/dongting/Api/Weather
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"post"];//请求方式
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];//头部信息//octet-stream
    
    NSString *strA = [[MBCatchErrorLog logInfo] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *strB = [[DeviceHelper getSystemInfo] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *pars = [NSString stringWithFormat:@"{\"projectId\":%@,\"systemInfo\":\"%@\",\"logData\":\"%@\",\"userInfo\":\"%@\"}",appKey,strB,strA,userInfo];
    
    [request setHTTPBody:[pars dataUsingEncoding:NSUTF8StringEncoding]];//参数内容
    [request setTimeoutInterval:20.0];//超时时间
    
    __weak typeof(self) weakSelf = self;
    NSOperationQueue *queue=[NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        NSDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];//解析结果
        NSLog(@"%@",[result descriptionWithLocale:nil]);
        
        block([result descriptionWithLocale:nil]);//上传成功后,回调block
    }];
}

+ (BOOL)isFileExists{
    if (![[NSFileManager defaultManager]fileExistsAtPath:LOGFilePath]) {
        return false;
    }
    return true;
}

+ (void)catchLog{
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //捕捉崩溃信息
        NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    }
    return self;
}

+ (void)printErrorLog{
    NSLog(@"path - %@ \nerrorLog - %@",LOGFilePath,[MBCatchErrorLog logInfo]);
}

+ (NSString *)logInfo{
    return [NSString stringWithContentsOfFile:LOGFilePath encoding:NSUTF8StringEncoding error:nil];
}

+ (NSData *)logData{
    return [[MBCatchErrorLog logInfo] dataUsingEncoding:NSUTF8StringEncoding];
}

+ (BOOL)delErrorLogFile{
    NSError * error;
    [[NSFileManager defaultManager] removeItemAtPath:LOGFilePath error:&error];
    
    if (!error) {
        return YES;
    }
    
    NSLog(@"\n删除失败 - %@",error);
    return NO;
}

//抓取奔溃日志
void UncaughtExceptionHandler(NSException *exception) {
    
    NSArray *arr = [exception callStackSymbols];//得到当前调用栈信息
    
    NSString *reason = [exception reason];//非常重要，就是崩溃的原因
    
    NSString *name = [exception name];//异常类型
    
//    NSDictionary *userInfo = [exception userInfo];
    
    NSMutableString * log = [NSMutableString stringWithFormat:@"callStackSymbols - 当前栈信息:\n"];
    for (NSString * str in arr) {
        [log appendFormat:@"%@\n",str];
    }
    [log appendFormat:@"\nreason - 崩溃原因：\n %@",reason];
    [log appendFormat:@"\nname - 异常类型：\n %@",name];
    
    [log insertString:[NSString stringWithFormat:@"*************** %@ *******************\n",[NSDate currentDateForDateSeconds]] atIndex:0];
    
    //创建一个文件 如果是第一次就直接写入，然后返回
    if (![[NSFileManager defaultManager]fileExistsAtPath:LOGFilePath]) {
        [[NSFileManager defaultManager]createFileAtPath:LOGFilePath contents:nil attributes:nil];
        [log insertString:[NSString stringWithFormat:@"\n*************** 奔溃日志 *******************\n"] atIndex:0];
        [log writeToFile:LOGFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        return;
    }
    
    //创建一个fileHandler
    NSFileHandle * fileHandler = [NSFileHandle fileHandleForWritingAtPath:LOGFilePath];
    //跳到文件末尾
    [fileHandler seekToEndOfFile];
    //写入文件
    [fileHandler writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    //关闭file Handler
    [fileHandler closeFile];
}


@end


@implementation NSDate (PQCatchErrorLog)

/**
 把当前时间转化字符串
 
 @return 当前时间字符串
 */
+ (NSString *)currentDateForDateSeconds{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString1 = [dateFormatter stringFromDate:[NSDate date]];
    NSString *destDateString = [destDateString1 substringFromIndex:2];
    return destDateString;
}

@end



@implementation NSString (PQCatchErrorLog)

/**
 为字符串添加地址
 
 @return 地址
 */
- (NSString *)byAppendToCacheDocument{
    NSString * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    return [path stringByAppendingPathComponent:self];
}

@end
