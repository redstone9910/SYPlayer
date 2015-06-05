//
//  MIBServer.h
//  SYPlayer
//
//  Created by YinYanhui on 15-4-7.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIBServer : NSObject

typedef void (^MIBCompleteBlock)(NSString *fileURL);

/** Get方法登录服务器 */
+(void)getLogonWithName:(NSString *)userName password:(NSString *)userPWD fileName:(NSString *)fileName onComplete:(MIBCompleteBlock)complete;
+(void)getLogonMD5WithName:(NSString *)userName password:(NSString *)userPWD fileName:(NSString *)fileName onComplete:(MIBCompleteBlock)complete;
+(void)postLogonWithName:(NSString *)userName password:(NSString *)userPWD fileName:(NSString *)fileName onComplete:(MIBCompleteBlock)complete;
+(void)postLogonMD5WithName:(NSString *)userName password:(NSString *)userPWD fileName:(NSString *)fileName onComplete:(MIBCompleteBlock)complete;
+(void)fetchURLWithFileName:(NSString *)fileName onComplete:(MIBCompleteBlock)complete;
@end
