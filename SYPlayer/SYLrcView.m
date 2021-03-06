//
//  SYLrcView.m
//  SYPlayer
//
//  Created by YinYanhui on 15/6/8.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYLrcView.h"
#import "SYLrcLine.h"

#define lineMargin 0.5

@interface SYLrcView ()
/** 歌词文本 SYLrcLine数组 */
@property (nonatomic,strong) NSArray * lines;
/** title */
@property (nonatomic,strong) UILabel *titleLabel;
@end

@implementation SYLrcView
/** 创建新LRC View */
+(instancetype) lrcView
{
    return [[self alloc] init];
}

-(instancetype)init{
    if (self = [super init]) {
        [self customInit];
    }
    return self;
}
-(void)customInit{
    [self addSubview:self.titleLabel];
    {
        NSLayoutConstraint *cnsT = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *cnsL = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint *cnsR = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        [self addConstraints:@[cnsT,cnsL,cnsR]];
    }
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect vframe = _customFrame;
    SYLrcLine *line = self.lines.lastObject;
    float height = CGRectGetMaxY(line.label.frame);
    if(height){
        vframe.size.height = height;
    }
    self.frame = vframe;
    if ([self.delegate respondsToSelector:@selector(lrcViewLineDidLayoutSubviews:)]) {
        [self.delegate lrcViewLineDidLayoutSubviews:self];
    }
//    NSLog(@"%@ layoutSubviews:%@",[self class],NSStringFromCGRect(self.frame));
}
-(void)checkUpdate:(SYLrcLine*)playingLine{
    BOOL update = YES;
    if (self.playingLine != playingLine) {
        self.prevLine = self.playingLine;
        self.playingLine = playingLine;

        if (!((self.prevLine == [self.lines lastObject]) && (self.playingLine == [self.lines firstObject]))){
            
            _currentTime = self.playingLine.startTime;
            _offset = self.playingLine.label.frame.origin.y;
            if (playingLine == nil) {
                _offset = 0;
            }
            if ([self.delegate respondsToSelector:@selector(lrcViewLineShouldUpdate:)]) {
                update = [self.delegate lrcViewLineShouldUpdate:self];
            }
            if (update) {
                [self nextSentence];
            }
        }
    }
}
/** 跳转到下一句(单句模式需要手动调用) */
-(void)nextSentence{
    [self.lines makeObjectsPerformSelector:@selector(updateState)];
    
    if ([self.delegate respondsToSelector:@selector(lrcViewLineDidUpdate:)]) {
        [self.delegate lrcViewLineDidUpdate:self];
    }
}
#pragma mark -  property
/** 设定LRC源文件 */
-(void)setLrcFile:(NSString *)lrcFile
{
    _lrcFile = lrcFile;
    
    for (UIView *label in self.subviews) {
        if ([label isKindOfClass:[UILabel class]]) {
            if (label != self.titleLabel) {
                [label removeFromSuperview];
            }
        }
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.lrcFile]) {
        self.titleLabel.text = @"未找到歌词";
    }
    else
    {
        self.titleLabel.text = @"";
        
        NSString * lrcString = [NSString stringWithContentsOfFile:self.lrcFile encoding:NSUTF8StringEncoding error:nil];
        lrcString = [lrcString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        NSArray *lrcFileLineArray = [lrcString componentsSeparatedByString:@"\n"];
        
        NSMutableArray *lines = [NSMutableArray array];
        for (NSString *lrcLineString in lrcFileLineArray) {
            SYLrcLine *lrcLine = [SYLrcLine lrcLineWithLine:lrcLineString];
            if(lrcLine.text.length == 0) continue;
            [lines addObject:lrcLine];
        }
        
        self.lines = [self bubbleSort:[lines copy]];
    }
    
    for (int index = 0; index < self.lines.count; index ++) {
        SYLrcLine *line = self.lines[index];
        UILabel *lastLable;
        if (index == 0) {
            lastLable = self.titleLabel;
        }else{
            SYLrcLine *playingLine = self.lines[index - 1];
            lastLable = playingLine.label;
        }
        line.label.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:line.label];
        {
            UIFont *font = line.label.font;
            
            NSLayoutConstraint *cnsT = [NSLayoutConstraint constraintWithItem:line.label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:lastLable attribute:NSLayoutAttributeBottom multiplier:1 constant:lineMargin * font.pointSize];
            NSLayoutConstraint *cnsL = [NSLayoutConstraint constraintWithItem:line.label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
            NSLayoutConstraint *cnsR = [NSLayoutConstraint constraintWithItem:line.label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
            [self addConstraints:@[cnsT,cnsL,cnsR]];
        }
        
        line.state = lineStateFuture;
    }
}

-(UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _titleLabel;
}
-(void)setCurrentTime:(float)currentTime{
    _currentTime = currentTime;
    
    SYLrcLine *playingLine;
    for (int index = 0; index < self.lines.count; index ++) {
        SYLrcLine *line = self.lines[index];
        if (line.endTime <= currentTime) {
            line.state = lineStatePast;
        }else if (line.startTime > currentTime) {
            line.state = lineStateFuture;
        }else if ((line.startTime <= currentTime) && (line.endTime > currentTime)) {
            line.state = lineStateCurrent;
            playingLine = line;
        }
    }
    
    [self checkUpdate:playingLine];
}
-(void)setOffset:(float)offset{
    _offset = offset;
    
    SYLrcLine *playingLine;
    for (int index = 0; index < self.lines.count; index ++) {
        SYLrcLine *line = self.lines[index];
        float lineY = line.label.frame.origin.y;
        float nextLineY = lineY + line.label.frame.size.height + 1;
        if (index < self.lines.count - 1) {
            SYLrcLine *nextLine = self.lines[index + 1];
            nextLineY = nextLine.label.frame.origin.y;
        }
        if (lineY > offset) {
            line.state = lineStateFuture;
        }else if (nextLineY <= offset) {
            line.state = lineStatePast;
        }else if ((lineY <= offset) && (nextLineY > offset)) {
            line.state = lineStateCurrent;
            playingLine = line;
        }
    }
    [self checkUpdate:playingLine];
}

-(void)setCustomFrame:(CGRect)customFrame{
    _customFrame = customFrame;
    
    [self layoutIfNeeded];
}
#pragma mark -  tools
/** 歌词排序 */
- (NSArray *)bubbleSort:(NSArray *)array
{
    NSMutableArray *src = [array mutableCopy];
    int i, y;
    
    for (i = 0; i < [src count] - 1; i++) {
        for (y = (int)[array count] - 1; y > i; y --) {
            SYLrcLine *line1 = [src objectAtIndex:y];
            SYLrcLine *line2 = [src objectAtIndex:y - 1];
            if (line1.startTime < line2.startTime) {
                [src exchangeObjectAtIndex:y-1 withObjectAtIndex:y];
            }
        }
    }
    
    SYLrcLine *startLine = [SYLrcLine lrcLineWithLine:@"[00:00.00] "];
    [src insertObject:startLine atIndex:0];
    
    SYLrcLine *line = src.lastObject;
    int time = line.startTime + 5;
    SYLrcLine *endLine = [SYLrcLine lrcLineWithLine:[NSString stringWithFormat:@"[%02d:%02d.00] ",time / 60,time % 60]];
    endLine.endTime = 3600 - 1;
    [src addObject:endLine];
    
    for (i = 0; i < [src count] - 1; i++){
        SYLrcLine *linePrefix = src[i];
        SYLrcLine *lineSuffix = src[i + 1];
        linePrefix.endTime = lineSuffix.startTime;
    }
    
    return [src copy];
}
@end
