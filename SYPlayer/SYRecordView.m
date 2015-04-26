//
//  SYRecordView.m
//  SYPlayer
//
//  Created by YinYanhui on 15-4-26.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYRecordView.h"
#define statusPlayingOriginText @"正在播放原文..."
#define statusRecordingText @"正在录音,请大声朗读!"
#define statusPlayingRecordText @"正在播放录音..."

typedef enum recordStatus{
    recordStatusPlayingOrigin,
    recordStatusRecording,
    recordStatusPlayingRecord,
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
/** 加载句子 */
-(BOOL)loadSentence:(NSString *)sentence lessonTitle:(NSString *)title duration:(float)duration completion:(recordCompletion)block
{
    self.recordSentence.text = sentence;
    self.timeTotal = duration;
    self.timeProgress = 0;
    self.status = recordStatusPlayingOrigin;
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(scheduleStatus:) userInfo:block repeats:YES];
    
    return YES;
}
/** 定时器回调 */
-(void)scheduleStatus:(NSTimer *)timer
{
    self.timeProgress += timer.timeInterval;
    if (self.timeProgress == self.timeTotal) {
        self.timeProgress = 0;
        if (self.status == recordStatusPlayingRecord) {
            recordCompletion block = timer.userInfo;
            [timer invalidate];
            timer = nil;
            block();
        }
        self.status ++;
    }
}
#pragma mark - Property
-(NSArray *)statusArray
{
    if (_statusArray == nil) {
        _statusArray = @[statusPlayingOriginText,statusRecordingText,statusPlayingRecordText];
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
    _timeProgress = timeProgress > self.timeTotal ? self.timeTotal : timeProgress;
    
    if (self.timeTotal > 0) {
        self.recordProgress.progress = self.timeProgress / self.timeTotal;
    }else{
        self.recordProgress.progress = 0;
    }
}
@end
