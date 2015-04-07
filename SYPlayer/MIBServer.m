//
//  MIBServer.m
//  SYPlayer
//
//  Created by YinYanhui on 15-4-7.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "MIBServer.h"
#import "NSString+Tools.h"

@implementation MIBServer

+(void)getLogonWithName:(NSString *)userName withPwd:(NSString *)userPWD
{
    NSString *urlStr = [NSString stringWithFormat:@"http://localhost/login.php?username=%@&password=%@",userName,userPWD];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *reuqest = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:reuqest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError == nil) {
            NSString *retStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"%@",retStr);
//                NSLog(@"%@",response.description);
            }];
        }
    }];
}

+(void)getLogonMD5WithName:(NSString *)userName withPwd:(NSString *)userPWD
{
    [self getLogonWithName:userName withPwd:[userPWD myMD5]];
}

+(void)postLogonWithName:(NSString *)userName withPwd:(NSString *)userPWD
{
    NSString *bodyStr = [NSString stringWithFormat:@"username=%@&password=%@",userName,userPWD];
    NSString *urlStr = [NSString stringWithFormat:@"http://localhost/login.php"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError == nil) {
            NSString *retStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                NSLog(@"%@",retStr);
            }];
        }
    }];
}
+(void)postLogonMD5WithName:(NSString *)userName withPwd:(NSString *)userPWD
{
    [self postLogonWithName:userName withPwd:[userPWD myMD5]];
}
@end
