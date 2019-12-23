//
//  DeviceHelper.h
//  CatchErrorLog抓取奔溃信息
//
//  Created by yintr on 2019/12/16.
//  Copyright © 2019 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceHelper : NSObject

///获取设备信息
+ (NSString *)getSystemInfo;

/// 当前系统名称
+ (NSString *)getSystemName;

/// 通用唯一识别码UUID
+ (NSString *)getUUID;

/// 当前系统版本号
+ (NSString *)getSystemVersion;

/// 国际化区域名称
+ (NSString *)getLocalizedModel;

/// 获取手机型号（字符串）
+ (NSString *)getDeviceName;

@end

NS_ASSUME_NONNULL_END
