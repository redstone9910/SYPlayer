//
//  SYAudioController.m
//  SYPlayer
//
//  Created by YinYanhui on 15-4-17.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYAudioController.h"

@implementation SYAudioController

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static SYAudioController *instance;
    
    static dispatch_once_t onceTolen;
    dispatch_once(&onceTolen, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}
@end
