//
//  MBCatchErrorLog.h
//  CatchErrorLog抓取奔溃信息
//
//  Created by yintr on 2019/12/16.
//  Copyright © 2019 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MBCatchErrorLog : NSObject

@property (strong, nonatomic) NSString *appkey;

/**
 抓取LOG。
 appKey:从日志系统获取项目ID。
 userInfo：登录后，获取的用户信息，保存的用户信息，eg："username:1380008000,nickname:魔豆青年"。
 */
+ (void)startCatchWithAppKey:(NSString *)appKey WithUserInfo:(NSString *)userInfo;


/**
 日志文件是否存在
 */
+ (BOOL)isFileExists;

/**
 抓取LOG
 */
+ (void)catchLog;


/**
 打印LOG信息
 */
+ (void)printErrorLog;


/**
 得到LOG信息

 @return log信息 - NSString
 */
+ (NSString *)logInfo;


/**
 得到LOG信息，以便于上传

 @return log信息 - Data
 */
+ (NSData *)logData;


/**
 删除error信息

 @return 返回是否删除成功
 */
+ (BOOL)delErrorLogFile;

@end


// ----------------   把时间转化为字符串     -----------------
@interface NSDate (PQCatchErrorLog)
/**
 把当前时间转化字符串
 
 @return 当前时间字符串
 */
+ (NSString *)currentDateForDateSeconds;
@end



// ----------------   文件地址拼接     -----------------
@interface NSString (PQCatchErrorLog)
/**
 为字符串添加地址
 
 @return 地址
 */
- (NSString *)byAppendToCacheDocument;
@end

