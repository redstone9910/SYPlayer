//
//  SYPlayerConsole.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-21.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYPlayerConsole.h"
#import "NSString+Tools.h"

@interface SYPlayerConsole ()
/** 总时间 */
@property (weak, nonatomic) IBOutlet UILabel *timeTotal;
/** 已播放时间 */
@property (weak, nonatomic) IBOutlet UILabel *timeProgress;
/** 播放进度 */
@property (weak, nonatomic) IBOutlet UISlider *playSlider;
/** 背景图片 */
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImg;
/** 播放模式按钮 */
@property (weak, nonatomic) IBOutlet UIButton *playModeBtn;
/** 退出 */
@property (weak, nonatomic) IBOutlet UIButton *powerBtn;
/** 播放/暂停按钮 */
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
/** 上一首 */
@property (weak, nonatomic) IBOutlet UIButton *prevBtn;
/** 下一首 */
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
/** 改变播放模式 */
- (IBAction)playModeClick;
/** 退出 */
- (IBAction)powerOff;
/** 播放/暂停 */
- (IBAction)playBtnClick;
/** 上一首 */
- (IBAction)prevBtnClick;
/** 下一首 */
- (IBAction)nextBtnClick;
/** 拖进度条 */
- (IBAction)progressChanged;
/** 进度条按下 */
- (IBAction)progressTouchDown;
/** 进度条抬起 */
- (IBAction)progressTouchUp;

/** 代理,传递按钮事件 */
@property(strong,nonatomic) id <SYPlayerConsoleDelegate> delegate;
/** 当前播放模式 */
@property (nonatomic,assign) playModeState playMode;
/** 正在滑动进度条 */
@property (nonatomic,assign) BOOL playSliderChanging;

/** 播放模式图片数组 */
@property (nonatomic,strong) NSArray * playModesAndImages;
@end

@implementation SYPlayerConsole

/** 创建新的console对象 */
+(instancetype)playerConsole
{
    NSBundle * bundle = [NSBundle mainBundle];
    NSArray * objs = [bundle loadNibNamed:NSStringFromClass(self) owner:nil options:nil];
    SYPlayerConsole * console = [objs lastObject];
    
    return console;
}
/** 改变播放模式按钮按下 */
- (IBAction)playModeClick {
#pragma - warning 此处应该使用遍历方法！更新
    if (++ self.playMode > 3) {
        self.playMode = playModeStateAllRecycle;
    }
}
/** 播放模式改变 */
-(void)setPlayMode:(playModeState)playMode
{
    if ([self.delegate respondsToSelector:@selector(playerConsole:playModeStateChanged:)]) {
        [self.delegate playerConsole:self playModeStateChanged:self.playMode];
    }
}
/** 退出键按下 */
- (IBAction)powerOff {
    if ([self.delegate respondsToSelector:@selector(playerConsolePowerOff:)]) {
        [self.delegate playerConsolePowerOff:self];
    }
}
/** 播放/暂停键按下 */
- (IBAction)playBtnClick {
    self.playing = !self.isPlaying;
    if ([self.delegate respondsToSelector:@selector(playerConsole:isPlayingStatusChanged:)]) {
        [self.delegate playerConsole:self isPlayingStatusChanged:self.isPlaying];
    }
}
/** 上一首 */
- (IBAction)prevBtnClick {
    if ([self.delegate respondsToSelector:@selector(playerConsolePrev:)]) {
        [self.delegate playerConsolePrev:self];
    }
}
/** 下一首 */
- (IBAction)nextBtnClick {
    if ([self.delegate respondsToSelector:@selector(playerConsoleNext:)]) {
        [self.delegate playerConsoleNext:self];
    }
}

/** 拖动进度条 */
- (IBAction)progressChanged {
    self.timeProgressInSecond = self.timeTotalInSecond * self.playSlider.value;
}

/** 开始拖动进度条，不允许更改value */
- (IBAction)progressTouchDown {
    self.playSliderChanging = YES;
}

/** 拖动进度条结束，允许更改value */
- (IBAction)progressTouchUp {
    self.playSliderChanging = NO;
}

/** 设定总时长并设定标签 */
-(void)setTimeTotalInSecond:(int)timeTotalInSecond
{
    _timeTotalInSecond = timeTotalInSecond;
    self.timeTotal.text = [NSString stringFromTime:self.timeTotalInSecond];
    self.timeProgressInSecond = 0;//已播放时长复位
}

/** 更新已播放时长 */
-(void)setTimeProgressInSecond:(int)timeProgressInSecond
{
    _timeProgressInSecond = timeProgressInSecond;
    self.timeProgress.text = [NSString stringFromTime:self.timeProgressInSecond];
    if(!self.playSliderChanging) self.playSlider.value = (float)self.timeProgressInSecond / (float)self.timeTotalInSecond;
    
    if ([self.delegate respondsToSelector:@selector(playerConsole:progressStatusChanged:)]) {
        [self.delegate playerConsole:self progressStatusChanged:self.playSlider.value];
    }
}
/** 从XIB加载完毕 */
-(void)awakeFromNib
{
    //设置进度条外观
    [self.playSlider setThumbImage:[UIImage imageNamed:@"dot"] forState:UIControlStateNormal];
    self.playSlider.maximumTrackTintColor = [UIColor blackColor];
    self.playSlider.minimumTrackTintColor = [UIColor lightGrayColor];
    self.playSliderChanging = NO;//没有正在拖动
    //初始化变量
    if (self.playModesAndImages == nil) {
        //        UIImage img = [UIImage imageNamed:]
        NSArray *imgNameArray = @[@"order",@"random",@"lock",@"order",];
        NSArray *modeNameArray = @[@"顺序播放",@"随机播放",@"单曲循环",@"单曲播放",];
    }
}
@end
