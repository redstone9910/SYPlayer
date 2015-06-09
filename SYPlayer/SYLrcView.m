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
/** 上一行歌词 */
@property (nonatomic,strong) SYLrcLine *lastLine;
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
    vframe.size.height = CGRectGetMaxY(line.label.frame);
    self.frame = vframe;
    if ([self.delegate respondsToSelector:@selector(lrcLineDidLayoutSubviews:)]) {
        [self.delegate lrcLineDidLayoutSubviews:self];
    }
//    NSLog(@"%@ layoutSubviews:%@",[self class],NSStringFromCGRect(self.frame));
}
-(void)checkUpdate:(SYLrcLine*)currentLine{
    BOOL update = YES;
    if (self.lastLine != currentLine) {
        self.lastLine = currentLine;
        _currentTime = self.lastLine.startTime;
        _offset = self.lastLine.label.frame.origin.y;
        if (currentLine == nil) {
            _offset = CGRectGetMaxY(self.bounds);
        }
        if ([self.delegate respondsToSelector:@selector(lrcLineShouldUpdate:)]) {
            update = [self.delegate lrcLineShouldUpdate:self];
        }
        if (update) {
            [self nextSentence];
        }
    }
}
/** 跳转到下一句(单句模式需要手动调用) */
-(void)nextSentence{
    [self.lines makeObjectsPerformSelector:@selector(updateState)];
    
    if ([self.delegate respondsToSelector:@selector(lrcLineDidUpdate:)]) {
        [self.delegate lrcLineDidUpdate:self];
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
            SYLrcLine *lastLine = self.lines[index - 1];
            lastLable = lastLine.label;
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
    
    SYLrcLine *currentLine;
    for (int index = 0; index < self.lines.count; index ++) {
        SYLrcLine *line = self.lines[index];
        if (line.endTime <= currentTime) {
            line.state = lineStatePast;
        }else if (line.startTime > currentTime) {
            line.state = lineStateFuture;
        }else if ((line.startTime <= currentTime) && (line.endTime > currentTime)) {
            line.state = lineStateCurrent;
            currentLine = line;
        }
    }
    
    [self checkUpdate:currentLine];
}
-(void)setOffset:(float)offset{
    _offset = offset;
    
    SYLrcLine *currentLine;
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
            currentLine = line;
        }
    }
    [self checkUpdate:currentLine];
}

-(void)setCustomFrame:(CGRect)customFrame{
    _customFrame = customFrame;
    
    [self layoutIfNeeded];
}
#pragma mark -  tools
/** 歌词排序 */
- (NSArray *)bubbleSort:(NSArray *)array
{
    NSMutableArray *src = [array copy];
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
    
    for (i = 0; i < [src count] - 1; i++){
        SYLrcLine *linePrefix = src[i];
        SYLrcLine *lineSuffix = src[i + 1];
        linePrefix.endTime = lineSuffix.startTime;
    }
    SYLrcLine *lineLast = [src lastObject];
    lineLast.endTime = lineLast.startTime + 5;
    
    return [src copy];
}
@end
