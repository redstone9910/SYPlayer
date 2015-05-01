//
//  SYRecordView.m
//  SYPlayer
//
//  Created by YinYanhui on 15-4-26.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYRecordView.h"
#import "Gloable.h"

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
    
//    NSNull *n = [NSNull null];
//    id block1 = pBlock;
//    if (pBlock == nil) {
//        block1 = n;
//    }
//    id block2 = rBlock;
//    if (rBlock == nil) {
//        block2 = n;
//    }
//    NSArray *blocks = @[block1, block2];
//    self.timerBlocks = blocks;
    
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
        
        if (self.status == recordStatusPlayingRecord) {
            self.status = recordStatusPlayingNone;
            recordCompletion block = timer.userInfo;
            [timer invalidate];
            timer = nil;
            
            block();
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
        block();
        return;
    }
    
    [self startTimer:block];
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
@end
