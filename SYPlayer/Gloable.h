//
//  Gloable.h
//  SYPlayer
//
//  Created by YinYanhui on 15-4-12.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#ifndef __SYPlayer__Gloable__
#define __SYPlayer__Gloable__

#include <stdio.h>

#define catchePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"]
#define SYLog(...) NSLog(...)
#define lightGreenColor [UIColor colorWithRed:79.0 / 255 green: 214.0 / 255 blue: 36.0 / 255 alpha:1]
/** 最后一句歌词长度 */
#define defaultInterval 5

#endif /* defined(__SYPlayer__Gloable__) */
