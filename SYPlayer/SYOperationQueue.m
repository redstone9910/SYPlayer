//
//  SYOperationQueue.m
//  SYPlayer
//
//  Created by YinYanhui on 15-6-3.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYOperationQueue.h"

@implementation SYOperationQueue

/** 单例 */
+(instancetype)sharedOperationQueue
{
    static SYOperationQueue *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance setMaxConcurrentOperationCount:1];
    });
    return instance;
}
@end
