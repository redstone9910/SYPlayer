//
//  MIBServer.m
//  SYPlayer
//
//  Created by YinYanhui on 15-4-7.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "MIBServer.h"
#import "NSString+Tools.h"

#define SERVER_ADDR @"http://www.xyuan360.com/"//@"http://www.ht501.cn/"//@"http://www.xyuan360.com/"

@implementation MIBServer

+(void)getLogonWithName:(NSString *)userName password:(NSString *)userPWD fileName:(NSString *)fileName onComplete:(MIBCompleteBlock)complete
{
    NSString *urlStr = [NSString stringWithFormat:@"%@login.php?username=%@&password=%@&filename=%@",SERVER_ADDR,userName,userPWD,fileName];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        __block NSString *filePath = nil;
        __block NSDictionary *dict = nil;
        if (connectionError == nil) {
            dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            filePath = dict[@"filePath"];
            if ([filePath hasPrefix:@"./"]) {
                filePath = [filePath stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:SERVER_ADDR];
            }
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            complete(filePath);
        }];
    }];
}

+(void)getLogonMD5WithName:(NSString *)userName password:(NSString *)userPWD fileName:(NSString *)fileName onComplete:(MIBCompleteBlock)complete
{
    [self getLogonWithName:userName password:[userPWD myMD5] fileName:fileName onComplete:complete];
}

+(void)postLogonWithName:(NSString *)userName password:(NSString *)userPWD fileName:(NSString *)fileName onComplete:(MIBCompleteBlock)complete
{
    NSString *bodyStr = [NSString stringWithFormat:@"username=%@&password=%@&filename=%@",userName,userPWD,fileName];
    NSString *urlStr = [NSString stringWithFormat:@"%@login.php",SERVER_ADDR];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        __block NSString *filePath = nil;
        __block NSDictionary *dict = nil;
        if (connectionError == nil) {
            dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            filePath = dict[@"filePath"];
            if ([filePath hasPrefix:@"./"]) {
                filePath = [filePath stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:SERVER_ADDR];
            }
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            complete(filePath);
        }];
    }];
}
+(void)postLogonMD5WithName:(NSString *)userName password:(NSString *)userPWD fileName:(NSString *)fileName onComplete:(MIBCompleteBlock)complete
{
    [self postLogonWithName:userName password:[userPWD myMD5] fileName:fileName onComplete:complete];
}
@end
