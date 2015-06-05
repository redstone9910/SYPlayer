//
//  SYAudioController.h
//  SYPlayer
//
//  Created by YinYanhui on 15-4-17.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "FSAudioController.h"
@class SYAuthor;
@class SYAudioController;
@class SYMediaInfo;

@protocol SYAudioControllerDelegate <NSObject>
@optional
-(void)SYAudioControllerTimerUpdate:(SYAudioController *)audioController;
-(void)SYAudioControllerWillPlay:(SYAudioController *)audioController;
-(void)SYAudioControllerPlaying:(SYAudioController *)audioController;
-(void)SYAudioControllerPause:(SYAudioController *)audioController;
-(void)SYAudioControllerStop:(SYAudioController *)audioController;
-(void)SYAudioControllerSeeking:(SYAudioController *)audioController;
-(void)SYAudioControllerBuffering:(SYAudioController *)audioController;
-(void)SYAudioControllerPlaybackComplete:(SYAudioController *)audioController;
-(void)SYAudioController:(SYAudioController *)audioController mediaInfoLoaded:(SYMediaInfo *)info;
-(void)SYAudioControllerFetchingURL:(SYAudioController *)audioController;
-(void)SYAudioControllerFetchURLFailed:(SYAudioController *)audioController;
-(void)SYAudioControllerFetchURLSuccess:(SYAudioController *)audioController;
@end

@interface SYAudioController : FSAudioController
/** 开始播放 */
-(void)startPlay;
/** 播放/暂停 */
@property (nonatomic,assign,getter=isPlaying) BOOL playing;
/** 停止 */
@property (nonatomic,assign) BOOL stopped;
/** 播放列表 */
@property (nonatomic,strong) SYAuthor * author;
/** 单例 */
+(instancetype)sharedAudioController;

/** 播放暂停控制 */
-(void)changePlayPauseStatus;

/** 代理 */
@property (nonatomic,weak) id<SYAudioControllerDelegate> sydelegate;
@end
