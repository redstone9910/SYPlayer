//
//  SYQueue.h
//  SYPlayer
//
//  Created by YinYanhui on 15-6-3.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYQueue : NSObject
@property (atomic,assign) dispatch_queue_t _queue;
@end
