//
//  SYPlayerConsole.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-21.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYPlayerConsole.h"
#import "NSString+Tools.h"
#import "Gloable.h"

#define timeLablePos 0.15
#define pnButtonPos 0.4
#define micButtonPos 0.175

@interface SYPlayerConsole ()
/** 总时间 */
@property (strong, nonatomic) IBOutlet UILabel *timeTotal;
/** 已播放时间 */
@property (strong, nonatomic) IBOutlet UILabel *timeProgress;
/** 播放进度 */
@property (strong, nonatomic) IBOutlet UISlider *playSlider;
/** 缓冲进度 */
@property (strong, nonatomic) IBOutlet UIProgressView *bufferProgressIndicator;
/** 背景图片 */
@property (strong, nonatomic) IBOutlet UIImageView *backGroundImageView;
/** 播放模式按钮 */
@property (strong, nonatomic) IBOutlet UIButton *playModeBtn;
/** 退出 */
@property (strong, nonatomic) IBOutlet UIButton *powerBtn;
/** 播放/暂停按钮 */
@property (strong, nonatomic) IBOutlet UIButton *playBtn;
/** 上一首 */
@property (strong, nonatomic) IBOutlet UIButton *prevBtn;
/** 下一首 */
@property (strong, nonatomic) IBOutlet UIButton *nextBtn;
/** 状态 */
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

/** 录音按钮 */
@property (strong, nonatomic) IBOutlet UIButton *micBtn;
/** mic图片 */
@property (strong, nonatomic) IBOutlet UIImageView *micImage;

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
    return [[self alloc]init];
}
/** 创建新的console对象 */
+(instancetype)playerConsoleWithNib
{
    NSBundle * bundle = [NSBundle mainBundle];
    NSArray * objs = [bundle loadNibNamed:NSStringFromClass(self) owner:nil options:nil];
    SYPlayerConsole * console = [objs lastObject];
    
    return console;
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
//        [self customInit];
    }
    return self;
}
/** 初始化代码 */
-(void)customInit
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.playSlider];
    {
        NSLayoutConstraint *cnsX = [NSLayoutConstraint constraintWithItem:self.playSlider attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *cnsY = [NSLayoutConstraint constraintWithItem:self.playSlider attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:0.25 constant:0];
        NSLayoutConstraint *cnsW = [NSLayoutConstraint constraintWithItem:self.playSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.7 constant:0];
        [self addConstraints:@[cnsX,cnsY,cnsW]];
    }
    [self addSubview:self.timeTotal];
    {
        NSLayoutConstraint *cnsY = [NSLayoutConstraint constraintWithItem:self.timeTotal attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.playSlider attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint *cnsX = [NSLayoutConstraint constraintWithItem:self.timeTotal attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:timeLablePos constant:0];
        [self addConstraints:@[cnsX,cnsY]];
    }
    [self addSubview:self.timeProgress];
    {
        NSLayoutConstraint *cnsY = [NSLayoutConstraint constraintWithItem:self.timeProgress attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.playSlider attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint *cnsX = [NSLayoutConstraint constraintWithItem:self.timeProgress attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:2 - timeLablePos constant:0];
        [self addConstraints:@[cnsX,cnsY]];
    }
    self.playing = NO;
    [self addSubview:self.playBtn];
    {
        NSLayoutConstraint *cnsX = [NSLayoutConstraint constraintWithItem:self.playBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *cnsY = [NSLayoutConstraint constraintWithItem:self.playBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:0.85 constant:0];
        [self addConstraints:@[cnsX,cnsY]];
        NSLayoutConstraint *cnsW = [NSLayoutConstraint constraintWithItem:self.playBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:46];
        NSLayoutConstraint *cnsH = [NSLayoutConstraint constraintWithItem:self.playBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:46];
        [self.playBtn addConstraints:@[cnsW,cnsH]];
    }
    [self addSubview:self.prevBtn];
    {
        NSLayoutConstraint *cnsX = [NSLayoutConstraint constraintWithItem:self.prevBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:pnButtonPos constant:0];
        NSLayoutConstraint *cnsY = [NSLayoutConstraint constraintWithItem:self.prevBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.playBtn attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [self addConstraints:@[cnsX,cnsY]];
        NSLayoutConstraint *cnsW = [NSLayoutConstraint constraintWithItem:self.prevBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:32];
        NSLayoutConstraint *cnsH = [NSLayoutConstraint constraintWithItem:self.prevBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:32];
        [self.prevBtn addConstraints:@[cnsW,cnsH]];
    }
    [self addSubview:self.nextBtn];
    {
        NSLayoutConstraint *cnsX = [NSLayoutConstraint constraintWithItem:self.nextBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:2 - pnButtonPos constant:0];
        NSLayoutConstraint *cnsY = [NSLayoutConstraint constraintWithItem:self.nextBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.playBtn attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [self addConstraints:@[cnsX,cnsY]];
        NSLayoutConstraint *cnsW = [NSLayoutConstraint constraintWithItem:self.nextBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:32];
        NSLayoutConstraint *cnsH = [NSLayoutConstraint constraintWithItem:self.nextBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:32];
        [self.nextBtn addConstraints:@[cnsW,cnsH]];
    }
    [self addSubview:self.micBtn];
    {
        NSLayoutConstraint *cnsX = [NSLayoutConstraint constraintWithItem:self.micBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:micButtonPos constant:0];
        NSLayoutConstraint *cnsY = [NSLayoutConstraint constraintWithItem:self.micBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.playBtn attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [self addConstraints:@[cnsX,cnsY]];
        NSLayoutConstraint *cnsW = [NSLayoutConstraint constraintWithItem:self.micBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:32];
        NSLayoutConstraint *cnsH = [NSLayoutConstraint constraintWithItem:self.micBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:32];
        [self.micBtn addConstraints:@[cnsW,cnsH]];
    }
    [self addSubview:self.micImage];
    {
        NSLayoutConstraint *cnsX = [NSLayoutConstraint constraintWithItem:self.micImage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.micBtn attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *cnsY = [NSLayoutConstraint constraintWithItem:self.micImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.micBtn attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [self addConstraints:@[cnsX,cnsY]];
        NSLayoutConstraint *cnsW = [NSLayoutConstraint constraintWithItem:self.micImage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:66];
        NSLayoutConstraint *cnsH = [NSLayoutConstraint constraintWithItem:self.micImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:40];
        [self.micImage addConstraints:@[cnsW,cnsH]];
    }
    [self addSubview:self.powerBtn];
    {
        NSLayoutConstraint *cnsX = [NSLayoutConstraint constraintWithItem:self.powerBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:2 - micButtonPos constant:0];
        NSLayoutConstraint *cnsY = [NSLayoutConstraint constraintWithItem:self.powerBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.playBtn attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [self addConstraints:@[cnsX,cnsY]];
        NSLayoutConstraint *cnsW = [NSLayoutConstraint constraintWithItem:self.powerBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:32];
        NSLayoutConstraint *cnsH = [NSLayoutConstraint constraintWithItem:self.powerBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:32];
        [self.powerBtn addConstraints:@[cnsW,cnsH]];
    }
    
    self.playModeBtn.hidden = YES;
    [self addSubview:self.playModeBtn];
    {
        NSLayoutConstraint *cnsX = [NSLayoutConstraint constraintWithItem:self.playModeBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.micBtn attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *cnsY = [NSLayoutConstraint constraintWithItem:self.playModeBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.micBtn attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [self addConstraints:@[cnsX,cnsY]];
        NSLayoutConstraint *cnsW = [NSLayoutConstraint constraintWithItem:self.playModeBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:32];
        NSLayoutConstraint *cnsH = [NSLayoutConstraint constraintWithItem:self.playModeBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:32];
        [self.playModeBtn addConstraints:@[cnsW,cnsH]];
    }
    [self addSubview:self.backGroundImageView];
    {
        NSLayoutConstraint *cnsT = [NSLayoutConstraint constraintWithItem:self.backGroundImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *cnsB = [NSLayoutConstraint constraintWithItem:self.backGroundImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint *cnsL = [NSLayoutConstraint constraintWithItem:self.backGroundImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint *cnsR = [NSLayoutConstraint constraintWithItem:self.backGroundImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        [self addConstraints:@[cnsT,cnsB,cnsL,cnsR]];
    }
    
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
-(UILabel *)timeTotal{
    if (_timeTotal == nil) {
        _timeTotal = [[UILabel alloc] init];
        _timeTotal.text = @"00:00";
        _timeTotal.textColor = lightGreenColor;
        _timeTotal.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _timeTotal;
}
-(UILabel *)timeProgress{
    if (_timeProgress == nil) {
        _timeProgress = [[UILabel alloc] init];
        _timeProgress.text = @"00:00";
        _timeProgress.textColor = lightGreenColor;
        _timeProgress.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _timeProgress;
}
-(UISlider *)playSlider{
    if (_playSlider == nil) {
        _playSlider = [[UISlider alloc] init];
        [_playSlider setThumbImage:[UIImage imageNamed:@"hp_player_progress_played"] forState:UIControlStateNormal];
        _playSlider.maximumTrackTintColor = [UIColor lightGrayColor];
        _playSlider.minimumTrackTintColor = lightGreenColor;
        [_playSlider addTarget:self action:@selector(progressTouchDown) forControlEvents:UIControlEventTouchDown];
        [_playSlider addTarget:self action:@selector(progressTouchUp) forControlEvents:UIControlEventTouchUpInside];
        [_playSlider addTarget:self action:@selector(progressTouchUp) forControlEvents:UIControlEventTouchUpOutside];
        [_playSlider addTarget:self action:@selector(progressChanged) forControlEvents:UIControlEventValueChanged];
        _playSlider.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.playSliderDraging = NO;//没有正在拖动
    }
    return _playSlider;
}
-(UIButton *)playBtn{
    if (_playBtn == nil) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _playBtn.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _playBtn;
}
-(UIButton *)prevBtn{
    if (_prevBtn == nil) {
        _prevBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_prevBtn setImage:[UIImage imageNamed:@"player_btn_pre_normal"] forState:UIControlStateNormal];
        [_prevBtn setImage:[UIImage imageNamed:@"player_btn_pre_highlight"] forState:UIControlStateHighlighted];
        [_prevBtn addTarget:self action:@selector(prevBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _prevBtn.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _prevBtn;
}
-(UIButton *)nextBtn{
    if (_nextBtn == nil) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextBtn setImage:[UIImage imageNamed:@"player_btn_next_normal"] forState:UIControlStateNormal];
        [_nextBtn setImage:[UIImage imageNamed:@"player_btn_next_highlight"] forState:UIControlStateHighlighted];
        [_nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _nextBtn.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _nextBtn;
}
-(UIButton *)powerBtn{
    if (_powerBtn == nil) {
        _powerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_powerBtn setImage:[UIImage imageNamed:@"btn_power"] forState:UIControlStateNormal];
        [_powerBtn addTarget:self action:@selector(powerOff) forControlEvents:UIControlEventTouchUpInside];
        _powerBtn.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _powerBtn;
}
-(UIButton *)micBtn{
    if (_micBtn == nil) {
        _micBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_micBtn setBackgroundColor:[UIColor clearColor]];
        [_micBtn addTarget:self action:@selector(micBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _micBtn.translatesAutoresizingMaskIntoConstraints = NO;
        self.recording = NO;
    }
    return _micBtn;
}
-(UIImageView *)micImage{
    if (_micImage == nil) {
        _micImage = [[UIImageView alloc] init];
        _micImage.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _micImage;
}
-(UIButton *)playModeBtn{
    if (_playModeBtn == nil) {
        _playModeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playModeBtn addTarget:self action:@selector(playModeClick) forControlEvents:UIControlEventTouchUpInside];
        _playModeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _playModeBtn;
}
-(UIImageView *)backGroundImageView{
    if (_backGroundImageView == nil) {
        _backGroundImageView = [[UIImageView alloc] init];
        _backGroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _backGroundImageView.backgroundColor = [UIColor clearColor];
    }
    return _backGroundImageView;
}
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
        currentImage = @"player_btn_pause";
    }else{
        currentImage = @"player_btn_play";
    }
    [self.playBtn setImage:[UIImage imageNamed:[currentImage stringByAppendingString:@"_normal"]] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:[currentImage stringByAppendingString:@"_highlight"]] forState:UIControlStateHighlighted];
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
    [self.backGroundImageView setImage:self.backgroundImage];
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
