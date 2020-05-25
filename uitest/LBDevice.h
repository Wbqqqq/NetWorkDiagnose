//
//  LBDevice.h
//  uitest
//
//  Created by 汪炳权 on 22.05.20.
//  Copyright © 2020 汪炳权. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBDevice : NSObject

/// 应用名称
+(NSString *)appName;

/// 应用版本
+(NSString *)appVersion;

/// 唯一设备号（uuid + keychain）
+(NSString *)deviceId;

/// 系统版本号
+(NSString *)systemVersion;

/// 运营商名称
+(NSString *)carrierName;

/// 当前网络类型
+(NSString *)networkType;

/// Wifi信号强度
+(NSString *)wifiSignalStrength;

@end

NS_ASSUME_NONNULL_END
