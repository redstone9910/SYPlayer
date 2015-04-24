//
//  SYPlayerConsole.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-21.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYPlayerConsole.h"
#import "NSString+Tools.h"
#warning 增加逐句录音功能
@interface SYPlayerConsole ()
/** 总时间 */
@property (weak, nonatomic) IBOutlet UILabel *timeTotal;
/** 已播放时间 */
@property (weak, nonatomic) IBOutlet UILabel *timeProgress;
/** 播放进度 */
@property (weak, nonatomic) IBOutlet UISlider *playSlider;
/** 缓冲进度 */
@property (weak, nonatomic) IBOutlet UIProgressView *bufferProgressIndicator;
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
/** 状态 */
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;


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

/** 正在滑动进度条 */
@property (nonatomic,assign) BOOL playSliderDraging;

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
/** 设定buffer进度并更新View */
-(void)setBufferProgress:(float)bufferProgress
{
    _bufferProgress = bufferProgress;
    self.bufferProgressIndicator.progress = self.bufferProgress;
}
/** 设定status并更新label */
-(void)setStatusText:(NSString *)statusText
{
    _statusText = statusText;
    self.statusLabel.text = self.statusText;
}
/** 改变播放模式按钮按下 */
- (IBAction)playModeClick {
    switch (self.playMode) {
        case playModeStateRepeat:
            self.playMode = playModeStateShuttle;
            break;
        case playModeStateShuttle:
            self.playMode = playModeStateSingleRepeat;
            break;
        case playModeStateSingleRepeat:
            self.playMode = playModeStateRepeat;
            break;
        default:
            break;
    }
}
/** 播放模式改变 */
-(void)setPlayMode:(playModeState)playMode
{
    _playMode = playMode;
    NSArray *playModeAndImage = self.playModesAndImages[self.playMode];
    NSString *imgNameStr = playModeAndImage[0];
    NSString *modeNameStr = playModeAndImage[1];
    [self.playModeBtn setImage:[UIImage imageNamed:imgNameStr] forState:UIControlStateNormal];
    
    if ([self.delegate respondsToSelector:@selector(playerConsolePlayModeStateChanged:withModeName:)]) {
        [self.delegate playerConsolePlayModeStateChanged:self withModeName:modeNameStr];
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
    if ([self.delegate respondsToSelector:@selector(playerConsolePlayingStatusChanged:)]) {
        [self.delegate playerConsolePlayingStatusChanged:self];
    }
}
/** 切换播放按钮图片 */
-(void)setPlaying:(BOOL)playing
{
    _playing = playing;
    if(self.isPlaying) self.stopped = NO;
    [self.playBtn setImage:[UIImage imageNamed:self.isPlaying ? @"btn_pause" : @"btn_play"] forState:UIControlStateNormal];
}

-(void)setStopped:(BOOL)stopped
{
    _stopped = stopped;
    if (self.isStopped) {
        self.timeTotalInSecond = 0;
        self.playBtn.enabled = NO;
    }else{
        self.playBtn.enabled = YES;
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

/** 开始拖动进度条，不允许更改value */
- (IBAction)progressTouchDown {
    self.playSliderDraging = YES;
}

/** 拖动进度条 */
- (IBAction)progressChanged {
    if(self.playSliderDraging)
    {
        self.timeProgressInSecond = self.timeTotalInSecond * self.playSlider.value;
        
        if ([self.delegate respondsToSelector:@selector(playerConsoleProgressChanged:)]) {
            [self.delegate playerConsoleProgressChanged:self];
        }
    }
}

/** 拖动进度条结束，允许更改value */
- (IBAction)progressTouchUp {
    self.playSliderDraging = NO;
}

/** 设定总时长并设定标签 */
-(void)setTimeTotalInSecond:(float)timeTotalInSecond
{
    _timeTotalInSecond = timeTotalInSecond;
    self.timeTotal.text = [NSString stringFromTime:self.timeTotalInSecond];
    self.timeProgressInSecond = 0;//已播放时长复位
}

/** 更新已播放时长 */
-(void)setTimeProgressInSecond:(float)timeProgressInSecond
{
    _timeProgressInSecond = timeProgressInSecond;
    self.timeProgress.text = [NSString stringFromTime:self.timeProgressInSecond];
    if(!self.playSliderDraging){
        self.playSlider.value = self.timeProgressInSecond / self.timeTotalInSecond;
    }
}
/** 更新背景图片 */
-(void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    [self.backGroundImg setImage:self.backgroundImage];
}

/** 从XIB加载完毕 */
-(void)awakeFromNib
{
    //设置进度条外观
    [self.playSlider setThumbImage:[UIImage imageNamed:@"dot"] forState:UIControlStateNormal];
    self.playSlider.maximumTrackTintColor = [UIColor blackColor];
    self.playSlider.minimumTrackTintColor = [UIColor lightGrayColor];
    self.playSliderDraging = NO;//没有正在拖动
    //初始化变量
    if (self.playModesAndImages == nil) {
        NSArray *imgNameArray = @[@"mode_repeat",@"mode_shuffle",@"mode_single_repeat"];
        NSArray *modeNameArray = @[@"顺序播放",@"随机播放",@"单曲循环"];
        NSMutableArray * temp = [NSMutableArray array];
        for (int i = 0; i < _PLAY_MODE_COUNT_; i ++) {
            NSArray *array = @[imgNameArray[i],modeNameArray[i]];
            [temp addObject:array];
        }
        self.playModesAndImages = temp;
    }
}
@end
