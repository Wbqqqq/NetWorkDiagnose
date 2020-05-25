//
//  KeychainTool.h
//  Keychain
//
//  Created by 汪炳权 on 16/6/11.
//  Copyright © 2016年 LW. All rights reserved.
//  一般用到的key是唯一的，我喜欢用项目的bundleID前缀进行拼接 ，所存储的keychain不会自动删除，那怕是把应用删除也不会删除，除非手动删除

#import <Foundation/Foundation.h>

@interface KeychainTool : NSObject

/**
 *  储存字符串到🔑钥匙串
 *
 *  @param sValue 对应的Value
 *  @param sKey   对应的Key
 */
+ (void)saveKeychainValue:(NSString *)sValue Key:(NSString *)sKey;

/**
 *  从🔑钥匙串获取字符串
 *
 *  @param sKey 对应的Key
 *
 *  @return 返回储存的Value
 */
+ (NSString *)readKeychainValue:(NSString *)sKey;

/**
 *  从🔑钥匙串删除字符串
 *
 *  @param sKey 对应的Key
 */
+ (void)deleteKeychainValue:(NSString *)sKey;

@end
