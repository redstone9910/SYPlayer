//
//  SYAudioController.m
//  SYPlayer
//
//  Created by YinYanhui on 15-4-17.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYAudioController.h"

@implementation SYAudioController
/** 单例 */
+(instancetype)sharedAudioController
{
    static SYAudioController *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

@end
