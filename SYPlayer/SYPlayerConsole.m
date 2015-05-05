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

/** 录音按钮 */
@property (weak, nonatomic) IBOutlet UIButton *micBtn;
/** mic图片 */
@property (weak, nonatomic) IBOutlet UIImageView *micImage;

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
/** 录音按钮按下 */
- (IBAction)micBtnClick;

/** 正在滑动进度条 */
@property (nonatomic,assign) BOOL playSliderDraging;

/** 播放模式图片数组 */
@property (nonatomic,strong) NSArray *modeImageArray;
@property (nonatomic,strong) NSArray *modeNameArray;
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
/** 从XIB加载完毕 */
-(void)awakeFromNib
{
}
/** 从代码初始化 */
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self customInit];
    }
    return self;
}
/** 从文件初始化 */
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self customInit];
    }
    return self;
}
/** 初始化代码 */
-(void)customInit
{
    //设置进度条外观
    [self.playSlider setThumbImage:[UIImage imageNamed:@"dot"] forState:UIControlStateNormal];
    self.playSlider.maximumTrackTintColor = [UIColor blackColor];
    self.playSlider.minimumTrackTintColor = [UIColor lightGrayColor];
    self.playSliderDraging = NO;//没有正在拖动
    
    self.recording = NO;
}
#pragma mark - IBAction
/** 改变播放模式按钮按下 */
- (IBAction)playModeClick {
    switch (self.playMode) {
        case playModeStateRepeat:
            self.playMode = playModeStateSingleSentenceRepeat;
            break;
        case playModeStateSingleSentenceRepeat:
            self.playMode = playModeStateRepeat;
            break;
//        case playModeStateRepeat:
//            self.playMode = playModeStateSingleSentenceRepeat;
//            break;
//        case playModeStateSingleSentenceRepeat:
//            self.playMode = playModeStateShuttle;
//            break;
//        case playModeStateShuttle:
//            self.playMode = playModeStateSingleRepeat;
//            break;
//        case playModeStateSingleRepeat:
//            self.playMode = playModeStateRepeat;
//            break;
        default:
            break;
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

/** 录音按钮按下 */
- (IBAction)micBtnClick {
    self.recording = !self.recording;
    if ([self.delegate respondsToSelector:@selector(playerConsoleRecordingStatusChanged:)]) {
        [self.delegate playerConsoleRecordingStatusChanged:self];
    }
}

#pragma mark - Property
/** 存储modeName的数组 */
-(NSArray *)modeImageArray
{
    if (_modeImageArray == nil) {
        _modeImageArray = @[@"mode_repeat",@"mode_single_repeat",@"mode_shuffle",@"mode_single_repeat"];
    }
    return _modeImageArray;
}
/** 存储modeName的数组 */
-(NSArray *)modeNameArray
{
    if (_modeNameArray == nil) {
        _modeNameArray = @[@"顺序播放",@"单句播放",@"随机播放",@"单曲循环"];
    }
    return _modeNameArray;
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
    NSString *str = [self.modeNameArray[self.playMode] copy];
    
    if (statusText != nil && [statusText length] > 0) {
        NSString *secondStr = statusText;
        NSArray *ary = [statusText componentsSeparatedByString:@" - "];
        if ([ary count] >= 2) {
            NSString *firstStr = ary[0];
            long index = firstStr.length;
            secondStr = [statusText substringFromIndex:index + 3];
        }
        str = [str stringByAppendingString:@" - "];
        str = [str stringByAppendingString:secondStr];
    }
    _statusText = [str copy];
    self.statusLabel.text = self.statusText;
}
/** 播放模式改变 */
-(void)setPlayMode:(playModeState)playMode
{
    _playMode = playMode;
    NSString *imgNameStr = self.modeImageArray[self.playMode];
    NSString *modeNameStr = self.modeNameArray[self.playMode];
    [self.playModeBtn setImage:[UIImage imageNamed:imgNameStr] forState:UIControlStateNormal];
    
    NSArray *ary = [self.statusText componentsSeparatedByString:@" - "];
    if (ary.count <= 1) {
        self.statusText = @"";
    }else{
        self.statusText = self.statusText;
    }
    
    if ([self.delegate respondsToSelector:@selector(playerConsolePlayModeStateChanged:withModeName:)]) {
        [self.delegate playerConsolePlayModeStateChanged:self withModeName:modeNameStr];
    }
}
/** 切换播放按钮图片 */
-(void)setPlaying:(BOOL)playing
{
    _playing = playing;
    if(self.isPlaying) self.stopped = NO;
    
    NSString *currentImage;
    if (self.isPlaying) {
        currentImage = @"btn_pause";
    }else{
        currentImage = @"btn_play";
    }
    [self.playBtn setImage:[UIImage imageNamed:currentImage] forState:UIControlStateNormal];
}
/** 更新播放/停止状态并使能/禁止播放按钮 */
-(void)setStopped:(BOOL)stopped
{
    _stopped = stopped;
    if (self.isStopped) {
        self.timeTotalInSecond = 0;
        self.playBtn.enabled = NO;
    }else if(!self.recording){
        self.playBtn.enabled = YES;
    }
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
/** 设定录音状态并更新图片 */
-(void)setRecording:(BOOL)recording
{
    _recording = recording;
    if (_recording) {
        self.playBtn.enabled = NO;
        self.nextBtn.enabled = NO;
        self.prevBtn.enabled = NO;
        self.playSlider.enabled = NO;
        
        NSString *scale = [NSString stringWithFormat:@"@%dx",(int)[UIScreen mainScreen].scale];
        NSMutableArray *ary = [NSMutableArray array];
        for (int i = 0; i < 6; i ++) {
            NSString *name = [NSString stringWithFormat:@"mic/mic%d%@.png",i + 1,scale];
            NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            [ary addObject:image];
        }
        self.micImage.animationImages = [ary copy];
        self.micImage.animationDuration = 4.0 / 6;
        [self.micImage startAnimating];
    }else{
        self.playBtn.enabled = YES;
        self.nextBtn.enabled = YES;
        self.prevBtn.enabled = YES;
        self.playSlider.enabled = YES;
        
        self.micImage.animationImages = nil;
        self.micImage.image = [UIImage imageNamed:@"mic0"];
    }
}
-(CGRect)recordFrame
{
    return self.micImage.frame;
}
@end
