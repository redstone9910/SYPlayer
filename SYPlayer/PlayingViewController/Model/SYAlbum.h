//
//  SYAlbum.h
//  SYPlayer
//
//  Created by YinYanhui on 15-4-2.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYModel.h"

@class SYSong;
@interface SYAlbum : SYModel
/** 册编号 */
@property (nonatomic,assign) long aindex;
/** SYSong Array 播放列表 */
@property (nonatomic,strong) NSArray * songs;
/** 正在播放 */
@property (nonatomic,assign) long playingIndex;
/** 前一首 */
@property (nonatomic,assign) long prevIndex;

/** 通过字典创建 */
+(instancetype)albumWithDict:(NSDictionary *)dict;

/** 检查列表中文件本地路径是否有更新 */
-(BOOL)updateCheck;

/** 正在播放的曲目 */
-(SYSong *)playingSong;
@end
