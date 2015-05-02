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

#define statusPlayingOriginText @"正在播放原文..."
#define statusRecordingText @"正在录音,请大声朗读!"
#define statusPlayingRecordText @"正在播放录音..."
#define statusNoneText @""

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
@property (weak, nonatomic) IBOutlet UILabel *recordStatus;
/** 原文文字 */
@property (weak, nonatomic) IBOutlet UILabel *recordSentence;
/** 播放/录制进度 */
@property (weak, nonatomic) IBOutlet UIProgressView *recordProgress;
/** 总时长 */
@property (nonatomic,assign) float timeTotal;
/** 播放进度 */
@property (nonatomic,assign) float timeProgress;
/** Timer */
@property (nonatomic,strong) NSTimer * updateTimer;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic,copy) NSString * recordPath;
@property (nonatomic,strong) FSAudioController *audioController;
@end

@implementation SYRecordView
/** 创建新对象 */
+(instancetype)recordView
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSArray *objs = [bundle loadNibNamed:NSStringFromClass(self) owner:nil options:nil];
    SYRecordView *recordView = [objs lastObject];
    
    return recordView;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self stop];
    }
    return self;
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
        
        if (self.status == recordStatusPlayingOrigin) {
            self.status = recordStatusPlayingNone;
            playCompletion block = timer.userInfo;
            [timer invalidate];
            timer = nil;
            
            block();
            return;
        }
        
        if (self.status == recordStatusRecording) {
            [self stopRecord];
            [self.audioController playFromURL:[NSURL fileURLWithPath:self.recordPath]];
        }
        if (self.status == recordStatusPlayingRecord) {
            self.status = recordStatusPlayingNone;
            recordCompletion block = timer.userInfo;
            [timer invalidate];
            timer = nil;
            
            block(self.recordPath);
            return;
        }
        
        self.status ++;
    }
}
/** 开始播放原音 */
-(void)startPlayCompletion:(playCompletion)block
{
    NSLog(@"startPlay:%@",self.recordSentence.text);
    self.status = recordStatusPlayingOrigin;
    
    if (self.timeTotal == 0) {//最后一句
        self.timeTotal = defaultInterval;
    }
    [self startTimer:block];
}
/** 开始录音 */
-(void)startRecordCompletion:(recordCompletion)block
{
    NSLog(@"startRecord:%@",self.recordSentence.text);
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
    NSLog(@"stop");
    self.status = recordStatusPlayingNone;
    self.recordSentence.text = nil;
    self.timeTotal = 0;
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
        _status = recordStatusPlayingOrigin;
    }
    self.recordStatus.text = self.statusArray[self.status];
}
-(void)setTimeProgress:(float)timeProgress
{
//    _timeProgress = timeProgress > self.timeTotal ? self.timeTotal : timeProgress;
    _timeProgress = timeProgress;
    
    if (self.timeTotal > 0) {
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
    // 停止定时器
    [self.link invalidate];
    self.link = nil;
    NSLog(@"停止录音");
}
@end
