//
//  LBDevice.m
//  uitest
//
//  Created by 汪炳权 on 22.05.20.
//  Copyright © 2020 汪炳权. All rights reserved.
//

#import "LBDevice.h"
#import "KeychainTool.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@implementation LBDevice

static NSString * _deviceId = nil;

+(NSString *)appName{
    NSString * appName;
    NSDictionary *dicBundle = [[NSBundle mainBundle] infoDictionary];
    appName = [dicBundle objectForKey:@"CFBundleDisplayName"];
    return appName;
}

+(NSString *)appVersion{
    NSString * appVersion;
    NSDictionary *dicBundle = [[NSBundle mainBundle] infoDictionary];
    appVersion = [dicBundle objectForKey:@"CFBundleShortVersionString"];
    return appVersion;
}

+(NSString *)deviceId{
    if(_deviceId) return _deviceId;
    NSString *keychainKey = [NSString stringWithFormat:@"%@-UUID",[NSBundle mainBundle].bundleIdentifier];
    NSString *strUUID = [KeychainTool readKeychainValue:keychainKey];
    if (strUUID.length <= 0) {
        strUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [KeychainTool saveKeychainValue:strUUID Key:keychainKey];
    }
     _deviceId = strUUID;
     return _deviceId;
}

+(NSString *)systemVersion{
    return [[UIDevice currentDevice] systemVersion];
}


+(NSString *)carrierName{
     CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
     CTCarrier *carrier = nil;
     if (@available(iOS 12.1, *)) {
        NSDictionary *dic = [info serviceSubscriberCellularProviders];
        if (dic.allKeys.count) {
            carrier = [dic objectForKey:dic.allKeys[0]];
        }
     } else {
        carrier = [info subscriberCellularProvider];
     }
     return [carrier carrierName];
}


+(NSString *)networkType{
    UIApplication *app = [UIApplication sharedApplication];
        id statusBar = nil;
    //    判断是否是iOS 13
        NSString *network = @"";
        if (@available(iOS 13.0, *)) {
            UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager;
            
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
            if ([statusBarManager respondsToSelector:@selector(createLocalStatusBar)]) {
                UIView *localStatusBar = [statusBarManager performSelector:@selector(createLocalStatusBar)];
                if ([localStatusBar respondsToSelector:@selector(statusBar)]) {
                    statusBar = [localStatusBar performSelector:@selector(statusBar)];
                }
            }
    #pragma clang diagnostic pop
            
            if (statusBar) {
    //            UIStatusBarDataCellularEntry
                id currentData = [[statusBar valueForKeyPath:@"_statusBar"] valueForKeyPath:@"currentData"];
                id _wifiEntry = [currentData valueForKeyPath:@"wifiEntry"];
                id _cellularEntry = [currentData valueForKeyPath:@"cellularEntry"];
                if (_wifiEntry && [[_wifiEntry valueForKeyPath:@"isEnabled"] boolValue]) {
    //                If wifiEntry is enabled, is WiFi.
                    network = @"WIFI";
                } else if (_cellularEntry && [[_cellularEntry valueForKeyPath:@"isEnabled"] boolValue]) {
                    NSNumber *type = [_cellularEntry valueForKeyPath:@"type"];
                    if (type) {
                        switch (type.integerValue) {
                            case 0:
    //                            无sim卡
                                network = @"NONE";
                                break;
                            case 1:
                                network = @"1G";
                                break;
                            case 4:
                                network = @"3G";
                                break;
                            case 5:
                                network = @"4G";
                                break;
                            default:
    //                            默认WWAN类型
                                network = @"WWAN";
                                break;
                                }
                            }
                        }
                    }
        }else {
            statusBar = [app valueForKeyPath:@"statusBar"];
            
            if ([self isIPhoneX]) {
    //            刘海屏
                    id statusBarView = [statusBar valueForKeyPath:@"statusBar"];
                    UIView *foregroundView = [statusBarView valueForKeyPath:@"foregroundView"];
                    NSArray *subviews = [[foregroundView subviews][2] subviews];
                    
                    if (subviews.count == 0) {
    //                    iOS 12
                        id currentData = [statusBarView valueForKeyPath:@"currentData"];
                        id wifiEntry = [currentData valueForKey:@"wifiEntry"];
                        if ([[wifiEntry valueForKey:@"_enabled"] boolValue]) {
                            network = @"WIFI";
                        }else {
    //                    卡1:
                            id cellularEntry = [currentData valueForKey:@"cellularEntry"];
    //                    卡2:
                            id secondaryCellularEntry = [currentData valueForKey:@"secondaryCellularEntry"];

                            if (([[cellularEntry valueForKey:@"_enabled"] boolValue]|[[secondaryCellularEntry valueForKey:@"_enabled"] boolValue]) == NO) {
    //                            无卡情况
                                network = @"NONE";
                            }else {
    //                            判断卡1还是卡2
                                BOOL isCardOne = [[cellularEntry valueForKey:@"_enabled"] boolValue];
                                int networkType = isCardOne ? [[cellularEntry valueForKey:@"type"] intValue] : [[secondaryCellularEntry valueForKey:@"type"] intValue];
                                switch (networkType) {
                                        case 0://无服务
                                        network = [NSString stringWithFormat:@"%@-%@", isCardOne ? @"Card 1" : @"Card 2", @"NONE"];
                                        break;
                                        case 3:
                                        network = [NSString stringWithFormat:@"%@-%@", isCardOne ? @"Card 1" : @"Card 2", @"2G/E"];
                                        break;
                                        case 4:
                                        network = [NSString stringWithFormat:@"%@-%@", isCardOne ? @"Card 1" : @"Card 2", @"3G"];
                                        break;
                                        case 5:
                                        network = [NSString stringWithFormat:@"%@-%@", isCardOne ? @"Card 1" : @"Card 2", @"4G"];
                                        break;
                                    default:
                                        break;
                                }
                                
                            }
                        }
                    
                    }else {
                        
                        for (id subview in subviews) {
                            if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]) {
                                network = @"WIFI";
                            }else if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarStringView")]) {
                                network = [subview valueForKeyPath:@"originalText"];
                            }
                        }
                    }
                    
                }else {
    //                非刘海屏
                    UIView *foregroundView = [statusBar valueForKeyPath:@"foregroundView"];
                    NSArray *subviews = [foregroundView subviews];
                    
                    for (id subview in subviews) {
                        if ([subview isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
                            int networkType = [[subview valueForKeyPath:@"dataNetworkType"] intValue];
                            switch (networkType) {
                                case 0:
                                    network = @"NONE";
                                    break;
                                case 1:
                                    network = @"2G";
                                    break;
                                case 2:
                                    network = @"3G";
                                    break;
                                case 3:
                                    network = @"4G";
                                    break;
                                case 5:
                                    network = @"WIFI";
                                    break;
                                default:
                                    break;
                            }
                        }
                    }
                }
        }

        if ([network isEqualToString:@""]) {
            network = @"NO DISPLAY";
        }
        return network;
}


+(NSString *)wifiSignalStrength{
    int signalStrength = 0;
    //    判断类型是否为WIFI
        if ([[self networkType] isEqualToString:@"WIFI"]) {
    //        判断是否为iOS 13
            if (@available(iOS 13.0, *)) {
                UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager;
                 
                id statusBar = nil;
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
                if ([statusBarManager respondsToSelector:@selector(createLocalStatusBar)]) {
                    UIView *localStatusBar = [statusBarManager performSelector:@selector(createLocalStatusBar)];
                    if ([localStatusBar respondsToSelector:@selector(statusBar)]) {
                        statusBar = [localStatusBar performSelector:@selector(statusBar)];
                    }
                }
    #pragma clang diagnostic pop
                if (statusBar) {
                    id currentData = [[statusBar valueForKeyPath:@"_statusBar"] valueForKeyPath:@"currentData"];
                    id wifiEntry = [currentData valueForKeyPath:@"wifiEntry"];
                    if ([wifiEntry isKindOfClass:NSClassFromString(@"_UIStatusBarDataIntegerEntry")]) {
    //                    层级：_UIStatusBarDataNetworkEntry、_UIStatusBarDataIntegerEntry、_UIStatusBarDataEntry
                        
                        signalStrength = [[wifiEntry valueForKey:@"displayValue"] intValue];
                    }
                }
            }else {
                UIApplication *app = [UIApplication sharedApplication];
                id statusBar = [app valueForKey:@"statusBar"];
                if ([self isIPhoneX]) {
    //                刘海屏
                    id statusBarView = [statusBar valueForKeyPath:@"statusBar"];
                    UIView *foregroundView = [statusBarView valueForKeyPath:@"foregroundView"];
                    NSArray *subviews = [[foregroundView subviews][2] subviews];
                           
                    if (subviews.count == 0) {
    //                    iOS 12
                        id currentData = [statusBarView valueForKeyPath:@"currentData"];
                        id wifiEntry = [currentData valueForKey:@"wifiEntry"];
                        signalStrength = [[wifiEntry valueForKey:@"displayValue"] intValue];
    //                    dBm
    //                    int rawValue = [[wifiEntry valueForKey:@"rawValue"] intValue];
                    }else {
                        for (id subview in subviews) {
                            if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]) {
                                signalStrength = [[subview valueForKey:@"_numberOfActiveBars"] intValue];
                            }
                        }
                    }
                }else {
    //                非刘海屏
                    UIView *foregroundView = [statusBar valueForKey:@"foregroundView"];
                         
                    NSArray *subviews = [foregroundView subviews];
                    NSString *dataNetworkItemView = nil;
                           
                    for (id subview in subviews) {
                        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
                            dataNetworkItemView = subview;
                            break;
                        }
                    }
                           
                    signalStrength = [[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] intValue];
                            
                    return [NSString stringWithFormat:@"%d",signalStrength];
                }
            }
        }
        return [NSString stringWithFormat:@"%d",signalStrength];;
}



#pragma mark 判断是否是刘海屏
+ (BOOL)isIPhoneX
{
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = [UIApplication sharedApplication].windows[0].safeAreaInsets;
        return safeAreaInsets.top == 44 || safeAreaInsets.bottom == 44 || safeAreaInsets.left == 44 || safeAreaInsets.right == 44;
    }else {
        return NO;
    }
}
@end
