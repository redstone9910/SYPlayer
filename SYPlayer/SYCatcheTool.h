//
//  SYCatcheTool.h
//  SYPlayer
//
//  Created by YinYanhui on 15-5-30.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SYAuthor;
@class SYAlbum;
@class SYSong;

@interface SYCatcheTool : NSObject
/** 插入 */
+(BOOL)insertData:(id)data;
/** 读取记录 */
+(NSArray *)loadData:(id) data;
@end
