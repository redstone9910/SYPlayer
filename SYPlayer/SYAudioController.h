//
//  SYAudioController.h
//  SYPlayer
//
//  Created by YinYanhui on 15-4-17.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "FSAudioController.h"
@class SYPlaylist;

@interface SYAudioController : FSAudioController
/** 播放列表 */
@property (nonatomic,strong) SYPlaylist * playList;
/** 单例 */
+(instancetype)sharedAudioController;
@end
