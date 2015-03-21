//
//  SYPlayerConsole.h
//  SYPlayer
//
//  Created by YinYanhui on 15-3-21.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SYPlayerConsole : UIView
/** 创建对象 */
+(instancetype)playerConsole;

/** 总时长，单位秒 */
@property (nonatomic,assign) int timeTotalInSecond;
/** 已播放时长 */
@property (nonatomic,assign) int timeProgressInSecond;
/** 正在播放/暂停 */
@property (nonatomic,assign,getter=isPlaying) BOOL playing;

typedef enum playModeState
{
    playModeStateAllRecycle = 0,
    playModeStateRandom = 1,
    playModeStateSingleRecycle = 2,
    playModeStateSingle = 3,
} playModeState;
@end

@protocol SYPlayerConsoleDelegate <NSObject>

/** 下一首 */
-(void)playerConsoleNext:(SYPlayerConsole *)console;
/** 上一首 */
-(void)playerConsolePrev:(SYPlayerConsole *)console;
/** 拖动进度条 */
-(void)playerConsole:(SYPlayerConsole *)console progressStatusChanged:(float)value;
/** 播放/暂停状态改变 */
-(void)playerConsole:(SYPlayerConsole *)console isPlayingStatusChanged:(BOOL)isPlaying;
/** 退出键按下 */
-(void)playerConsolePowerOff:(SYPlayerConsole *)console;
/** 播放模式改变 */
-(void)playerConsole:(SYPlayerConsole *)console playModeStateChanged:(playModeState)state;

@end