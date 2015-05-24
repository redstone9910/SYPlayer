//
//  SYPlaylist.h
//  SYPlayer
//
//  Created by YinYanhui on 15-4-2.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYPlaylist : NSObject
/** 第x册 */
@property (nonatomic,copy) NSString * lessonTitle;
/** SYSong Array 播放列表 */
@property (nonatomic,strong) NSArray * songs;
/** 正在播放 */
@property (nonatomic,assign) long playingIndex;
/** 前一首 */
@property (nonatomic,assign) long prevIndex;

/** 通过字典创建 */
+(instancetype)playListWithDict:(NSDictionary *)dict;
/** 模型转字典 */
-(NSDictionary *)toDict;
@end
