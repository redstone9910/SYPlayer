//
//  SYOperationQueue.h
//  SYPlayer
//
//  Created by YinYanhui on 15-6-3.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYOperationQueue : NSOperationQueue

/** 单例 */
+(instancetype)sharedOperationQueue;
@end
