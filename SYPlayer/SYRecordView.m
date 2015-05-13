//
//  SYRecordView.m
//  SYPlayer
//
//  Created by YinYanhui on 15-4-26.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYRecordView.h"
#import "Gloable.h"
#import <AVFoundation/AVFoundation.h>
#import "FSAudioController.h"
#import "EVCircularProgressView.h"

#define statusPlayingOriginText @"播放原文"
#define statusRecordingText @"请大声朗读!"
#define statusPlayingRecordText @"播放录音"
#define statusNoneText @""

#define alphaUnavailable 0.8
#define alphaAvailable 0.8
/** fontSizeScale=文字高度/中央图片高度 */
#define fontSizeScale 0.2
#define kDuration (4.0 / 6)
#define kMicScale 0.6

typedef enum recordStatus{
    recordStatusPlayingOrigin,
    recordStatusRecording,
    recordStatusPlayingRecord,
    recordStatusPlayingNone,
}recordStatus;

@interface SYRecordView ()
/** 状态数组 */
@property (nonatomic,strong) NSArray * statusArray;
/** 状态 */
@property (nonatomic,assign) recordStatus status;
/** 状态:正在播放原文.../请大声朗读! */
@property (strong, nonatomic) UILabel *recordStatus;
/** 原文文字 */
@property (strong, nonatomic) UILabel *recordSentence;
/** 播放/录制进度 */
@property (strong, nonatomic) EVCircularProgressView *recordProgress;
/** 中央状态图片 */
@property (nonatomic,strong) UIImageView * statusImage;
/** 总时长 */
@property (nonatomic,assign) float timeTotal;
/** Timer */
@property (nonatomic,strong) NSTimer * updateTimer;
/** 录音图组 */
@property (nonatomic,strong) NSArray * micImages;
/** 播放图组 */
@property (nonatomic,strong) NSArray * speakerImages;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic,copy) NSString * recordPath;
@property (nonatomic,strong) FSAudioController *audioController;
@end

@implementation SYRecordView
/** 创建新对象 */
+(instancetype)recordView
{
    return [[self alloc] init];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self customInit];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self customInit];
    }
    return self;
}
-(void)customInit
{
    [self stop];
    self.userInteractionEnabled = NO;
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    //宽高比固定
    NSLayoutConstraint *cnsR0 = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self addConstraint:cnsR0];
    
    /** recordProgress设定约束 */
    [self addSubview:self.recordProgress];
    self.recordProgress.translatesAutoresizingMaskIntoConstraints = NO;
    //top对齐
    NSLayoutConstraint *cnsTop = [NSLayoutConstraint constraintWithItem:self.recordProgress attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [self addConstraint:cnsTop];
    //NSLayoutAttributeLeading对齐
    NSLayoutConstraint *cnsLeading = [NSLayoutConstraint constraintWithItem:self.recordProgress attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [self addConstraint:cnsLeading];
    //NSLayoutAttributeTrailing对齐
    NSLayoutConstraint *cnsTrailing = [NSLayoutConstraint constraintWithItem:self.recordProgress attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [self addConstraint:cnsTrailing];
    
    //宽高比固定
    NSLayoutConstraint *cnsR1 = [NSLayoutConstraint constraintWithItem:self.recordProgress attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.recordProgress attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self.recordProgress addConstraint:cnsR1];
    
    /** statusImage设定约束 */
    self.statusImage = [[UIImageView alloc] init];
    [self addSubview:self.statusImage];
    self.statusImage.translatesAutoresizingMaskIntoConstraints = NO;
    //水平宽度
    self.micScale = 0.6;
    NSLayoutConstraint *cnsW2 = [NSLayoutConstraint constraintWithItem:self.statusImage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:self.micScale constant:0];
    [self addConstraint:cnsW2];
    //水平居中
    NSLayoutConstraint *cnsLeading2 = [NSLayoutConstraint constraintWithItem:self.statusImage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [self addConstraint:cnsLeading2];
    //垂直居中
    NSLayoutConstraint *cnsTrailing2 = [NSLayoutConstraint constraintWithItem:self.statusImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self addConstraint:cnsTrailing2];
    //宽高比固定
    NSLayoutConstraint *cnsR2 = [NSLayoutConstraint constraintWithItem:self.statusImage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.statusImage attribute:NSLayoutAttributeHeight multiplier:395.0 / 242.0 constant:0];
    [self.statusImage addConstraint:cnsR2];
    
    /** recordStatus设定约束 */
    self.recordStatus = [[UILabel alloc] init];
    self.recordStatus.textAlignment = NSTextAlignmentCenter;
    self.recordStatus.numberOfLines = 1;
    self.recordStatus.textColor = lightGreenColor;
    [self addSubview:self.recordStatus];
    self.recordStatus.translatesAutoresizingMaskIntoConstraints = NO;
    //top对齐
    NSLayoutConstraint *cnsTop3 = [NSLayoutConstraint constraintWithItem:self.recordStatus attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.statusImage attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self addConstraint:cnsTop3];
    //NSLayoutAttributeLeading对齐
    NSLayoutConstraint *cnsLeading3 = [NSLayoutConstraint constraintWithItem:self.recordStatus attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.statusImage attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [self addConstraint:cnsLeading3];
    //NSLayoutAttributeTrailing对齐
    NSLayoutConstraint *cnsTrailing3 = [NSLayoutConstraint constraintWithItem:self.recordStatus attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.statusImage attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [self addConstraint:cnsTrailing3];
    
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    float fontSize = self.statusImage.bounds.size.height * fontSizeScale;
    self.recordStatus.font = [UIFont systemFontOfSize:fontSize];
}
/** 加载句子 */
-(BOOL)loadSentence:(NSString *)sentence lessonTitle:(NSString *)title duration:(float)duration
{
    self.recordSentence.text = sentence;
    self.timeTotal = duration;
    self.timeProgress = 0;
    self.status = recordStatusPlayingOrigin;
    
    return YES;
}
/** 定时器回调 */
-(void)scheduleStatus:(NSTimer *)timer
{
    self.timeProgress = self.timeProgress + timer.timeInterval;
    if (self.timeProgress >= self.timeTotal) {
        self.timeProgress = 0;
        
        /** 播放原音结束 */
        if (self.status == recordStatusPlayingOrigin) {
            playCompletion block = timer.userInfo;
            
            [timer invalidate];
            timer = nil;
            
            block();
            return;
        }
        
        /** 录音结束 */
        if (self.status == recordStatusRecording) {
            [self stopRecord];
            [self.audioController playFromURL:[NSURL fileURLWithPath:self.recordPath]];
            self.status = recordStatusPlayingRecord;
            return;
        }
        
        /** 播放录音结束 */
        if (self.status == recordStatusPlayingRecord) {
            recordCompletion block = timer.userInfo;
            
            [timer invalidate];
            timer = nil;
            
            block(self.recordPath);
            return;
        }
    }
}
/** 开始播放原音 */
-(void)startPlayCompletion:(playCompletion)block
{
    self.status = recordStatusPlayingOrigin;
    
    if (self.timeTotal == 0) {//最后一句
        self.timeTotal = defaultInterval;
    }
    
    [self startTimer:block];
}
/** 开始录音 */
-(void)startRecordCompletion:(recordCompletion)block
{
    self.status = recordStatusRecording;
    if (self.timeTotal == 0) {
        block(nil);
        return;
    }
    
    if ([self startRecord]) {
        [self startTimer:block];
    } else {
        block(nil);
    }
}

-(void)startTimer:(id)userInfo
{
    self.timeProgress = 0;
    if (self.updateTimer) {
        [self.updateTimer invalidate];
        self.updateTimer = nil;
    }
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(scheduleStatus:) userInfo:userInfo repeats:YES];
}
/** 停止 */
-(void)stop
{
//    NSLog(@"stop");
    self.status = recordStatusPlayingNone;
    self.recordSentence.text = nil;
    
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    
    [self.audioController stop];
}
#pragma mark - Property
-(NSArray *)statusArray
{
    if (_statusArray == nil) {
        _statusArray = @[statusPlayingOriginText,statusRecordingText,statusPlayingRecordText,statusNoneText];
    }
    return _statusArray;
}
-(void)setStatus:(recordStatus)status
{
    _status = status;
    if (_status > recordStatusPlayingRecord) {
        _status = recordStatusPlayingNone;
    }
    
    switch (_status) {
        case recordStatusPlayingNone:
            self.alpha = alphaUnavailable;
            [self.statusImage stopAnimating];
            self.statusImage.animationImages = nil;
            self.statusImage.image = nil;
            self.timeTotal = 0;
            self.recordProgress.progress = 0;
            break;
        case recordStatusPlayingOrigin:
            self.alpha = alphaUnavailable;
            [self.statusImage stopAnimating];
            self.statusImage.animationImages = nil;
            self.statusImage.image = [UIImage imageNamed:@"mic1"];
            self.recordProgress.progress = 0;
            break;
        case recordStatusRecording:
            self.alpha = alphaAvailable;
            self.statusImage.animationImages = self.micImages;
            self.statusImage.animationDuration = 4.0 / 6;
            [self.statusImage startAnimating];
            break;
        case recordStatusPlayingRecord:
            self.alpha = alphaAvailable;
            self.statusImage.animationImages = self.speakerImages;
            self.statusImage.animationDuration = 4.0 / 6;
            [self.statusImage startAnimating];
            break;
        default:
            break;
    }
    
    float fontSize = self.statusImage.bounds.size.height * fontSizeScale;
    self.recordStatus.font = [UIFont systemFontOfSize:fontSize];
    self.recordStatus.text = self.statusArray[self.status];
}
-(void)setTimeProgress:(float)timeProgress
{
    _timeProgress = timeProgress;
    
    if ((self.timeTotal > 0) && (self.status != recordStatusPlayingOrigin) && (self.status != recordStatusPlayingNone)) {
        self.recordProgress.progress = self.timeProgress / self.timeTotal;
    }else{
        self.recordProgress.progress = 0;
    }
}
-(FSAudioController *)audioController
{
    if (_audioController == nil) {
        _audioController = [[FSAudioController alloc] init];
    }
    return _audioController;
}

- (CADisplayLink *)link
{
    if (!_link) {
        self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    }
    return _link;
}

-(NSArray *)micImages
{
    if (_micImages == nil) {
        NSMutableArray *images = [NSMutableArray array];
        for (int i = 0; i < 6; i ++) {
            NSString *imageName = [NSString stringWithFormat:@"mic%d",i + 1];
            UIImage *image = [UIImage imageNamed:imageName];
            [images addObject:image];
        }
        _micImages = [images copy];
    }
    return _micImages;
}

-(NSArray *)speakerImages
{
    if (_speakerImages == nil) {
        NSMutableArray *images = [NSMutableArray array];
        for (int i = 0; i < 4; i ++) {
            NSString *imageName = [NSString stringWithFormat:@"speaker%d",i + 1];
            UIImage *image = [UIImage imageNamed:imageName];
            [images addObject:image];
        }
        _speakerImages = [images copy];
    }
    return _speakerImages;
}
-(EVCircularProgressView *)recordProgress
{
    if (_recordProgress == nil) {
        _recordProgress = [[EVCircularProgressView alloc] init];
    }
    return _recordProgress;
}
-(void)setAnimating:(BOOL)animating
{
    _animating = animating;
    if (_animating) {
        self.recordProgress.hidden = YES;
        self.recordStatus.hidden = YES;
    }else{
        self.recordProgress.hidden = NO;
        self.recordStatus.hidden = NO;
    }
}
#pragma mark - record

- (void)update
{
    static double slientDuration = 0;
    // 1.更新录音器的测量值
    [self.recorder updateMeters];
    
    // 2.获得平均分贝
    float power = [self.recorder averagePowerForChannel:0];
    
    // 3.如果小于-30, 开始静音
    if (power < - 30) {
//        [self.recorder pause];
        slientDuration += self.link.duration;
        
        if (slientDuration >= 2) { // 沉默至少2秒钟
            NSLog(@"沉默至少2秒钟");
            [self stopRecord];
        }
    } else {
        [self.recorder record];
        slientDuration = 0;
//        NSLog(@"**********持续说话");
    }
}

- (BOOL)startRecord {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    
    self.recordPath = [catchePath stringByAppendingPathComponent:@"test.aac"];
    NSURL *url = [NSURL fileURLWithPath:self.recordPath];
    
    // 1.创建录音器
    //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:nil];
    
    // 允许测量分贝
    recorder.meteringEnabled = YES;
    
    // 2.缓冲
    BOOL ret = [recorder prepareToRecord];
    
    // 3.录音
    [recorder record];
    
    self.recorder = recorder;
    
    // 4.开启定时器
//    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    return ret;
}
-(void)stopRecord
{
    [self.recorder stop];
    self.recorder = nil;
    // 停止定时器
    [self.link invalidate];
    self.link = nil;
}
-(void)dealloc
{
//    NSLog(@"%@ dealloc!",NSStringFromClass(self.class));
}
@end
