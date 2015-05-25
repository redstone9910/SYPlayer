//
//  SYAudioController.h
//  SYPlayer
//
//  Created by YinYanhui on 15-4-17.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "FSAudioController.h"
@class SYPlaylists;
@class SYAudioController;

@protocol SYAudioControllerDelegate <NSObject>
@optional
-(void)SYAudioControllerTimerUpdate:(SYAudioController *)audiocontroller;
@end

@interface SYAudioController : FSAudioController
/** 播放/暂停 */
@property (nonatomic,assign,getter=isPlaying) BOOL playing;
/** 停止 */
@property (nonatomic,assign) BOOL stopped;
/** 播放列表 */
@property (nonatomic,strong) SYPlaylists * volumes;
/** 单例 */
+(instancetype)sharedAudioController;
@property (nonatomic,weak) id<SYAudioControllerDelegate> sydelegate;
@end
