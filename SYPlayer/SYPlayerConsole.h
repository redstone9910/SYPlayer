//
//  SYPlayerConsole.h
//  SYPlayer
//
//  Created by YinYanhui on 15-3-21.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYPlayerConsole;

typedef enum playModeState
{
    playModeStateRepeat = 0,
    playModeStateSingleSentenceRepeat = 1,
    playModeStateShuttle = 2,
    playModeStateSingleRepeat = 3,
} playModeState;

@protocol SYPlayerConsoleDelegate <NSObject>
@optional
/** 下一首 */
-(void)playerConsoleNext:(SYPlayerConsole *)console;
/** 上一首 */
-(void)playerConsolePrev:(SYPlayerConsole *)console;
/** 拖动进度条 */
-(void)playerConsoleProgressChanged:(SYPlayerConsole *)console ;
/** 播放/暂停状态改变 */
-(void)playerConsolePlayingStatusChanged:(SYPlayerConsole *)console;
/** 退出键按下 */
-(void)playerConsolePowerOff:(SYPlayerConsole *)console;
/** 播放模式改变 */
-(void)playerConsolePlayModeStateChanged:(SYPlayerConsole *)console withModeName:(NSString *)name;
@end

@interface SYPlayerConsole : UIView
/** 创建对象 */
+(instancetype)playerConsole;

/** 总时长，单位秒 */
@property (nonatomic,assign) float timeTotalInSecond;
/** 已播放时长 */
@property (nonatomic,assign) float timeProgressInSecond;
/** 正在播放/暂停 */
@property (nonatomic,assign,getter=isPlaying) BOOL playing;
/** 停止 */
@property (nonatomic,assign,getter=isStopped) BOOL stopped;
/** console背景图片 */
@property (nonatomic,strong) UIImage * backgroundImage;
/** 当前播放模式 */
@property (nonatomic,assign) playModeState playMode;
/** 缓冲进度值 */
@property (nonatomic,assign) float bufferProgress;
/** status字符串 */
@property (nonatomic,copy) NSString * statusText;
/** mode名 */
@property (nonatomic,strong) NSArray * modeNames;

/** 代理,传递按钮事件 */
@property(weak,nonatomic) id <SYPlayerConsoleDelegate> delegate;
@end
