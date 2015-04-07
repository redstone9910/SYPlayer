//
//  MIBServer.h
//  SYPlayer
//
//  Created by YinYanhui on 15-4-7.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIBServer : NSObject

/** Get方法登录服务器 */
+(void)getLogonWithName:(NSString *)userName withPwd:(NSString *)userPWD;
+(void)getLogonMD5WithName:(NSString *)userName withPwd:(NSString *)userPWD;
+(void)postLogonWithName:(NSString *)userName withPwd:(NSString *)userPWD;
+(void)postLogonMD5WithName:(NSString *)userName withPwd:(NSString *)userPWD;
@end
