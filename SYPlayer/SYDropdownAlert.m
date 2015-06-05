//
//  SYDropdownAlert.m
//  SYPlayer
//
//  Created by YinYanhui on 15-5-26.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYDropdownAlert.h"
#import "Gloable.h"

@implementation SYDropdownAlert
+(void)showText:(NSString *)text{
    SYLog(text);
    [self title:nil message:text backgroundColor:lightGreenColor textColor:[UIColor whiteColor] time:10];
}
@end
