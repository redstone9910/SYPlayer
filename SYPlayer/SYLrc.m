//
//  SYPlayerLrcView.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-22.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//
#warning 用Quartz2D重写单行进度
#import "SYLrc.h"
#import "NSString+Tools.h"
#import "Gloable.h"
#import "SYGradientView.h"
#import "SYLrcLine.h"
#import "SYLrcView.h"
#import "SYSong.h"

#define lrcOffset 0.3
#define edgeInsets 10

@interface SYLrc ()<UIScrollViewDelegate,SYLrcViewDelegate>
/** 用于显示歌词的Scroll */
@property (strong, nonatomic) SYGradientView *lrcScroll;
/** 歌词 */
@property (nonatomic,strong) SYLrcView * lrcView;
/** 正在拖动 */
@property (nonatomic,assign) BOOL lrcDragging;
/** 当前offset */
@property (nonatomic,assign) float offset;
@end

@implementation SYLrc
/** 创建新LRC View */
+(instancetype) lrc
{
    return [[self alloc] init];
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self customInit];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self customInit];
    }
    return self;
}
-(void)customInit{
    self.backgroundColor = [UIColor clearColor];
    
    self.lrcDragging = NO;
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.lrcScroll];
    {
        NSLayoutConstraint *cnsT = [NSLayoutConstraint constraintWithItem:self.lrcScroll attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *cnsB = [NSLayoutConstraint constraintWithItem:self.lrcScroll attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint *cnsL = [NSLayoutConstraint constraintWithItem:self.lrcScroll attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint *cnsR = [NSLayoutConstraint constraintWithItem:self.lrcScroll attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        [self addConstraints:@[cnsT,cnsB,cnsL,cnsR]];
    }
    [self.lrcScroll addSubview:self.lrcView];
    self.clearMode = NO;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect frame = self.lrcScroll.frame;
    frame.origin.y += frame.size.height * lrcOffset;
    frame.size.width -= edgeInsets * 2;
    self.lrcView.customFrame = frame;
    
    self.lrcScroll.contentOffset = CGPointMake(-edgeInsets, 0);
//    NSLog(@"%@ layoutSubviews self.lrcView:%@",[self class],NSStringFromCGRect(self.lrcView.frame));
//    NSLog(@"%@ layoutSubviews lrcScroll:%@",[self class],NSStringFromCGSize(self.lrcScroll.contentSize));
//    NSLog(@"%@ layoutSubviews self:%@",[self class],NSStringFromCGRect(self.frame));
}

/** 跳转到下一句(单句模式需要手动调用) */
-(void)nextSentence
{
    [self.lrcView nextSentence];
    [UIView animateWithDuration:0.3 animations:^{
        self.lrcScroll.contentOffset = CGPointMake(-edgeInsets, self.offset);
    }];
}
#pragma mark - Property
/** 设定播放进度并更新View */
-(void)setTimeProgressInSecond:(float)timeProgressInSecond
{
    _timeProgressInSecond = timeProgressInSecond;
    
    if (!self.lrcDragging) {
        self.lrcView.currentTime = _timeProgressInSecond;
    }
}

-(UIScrollView *)lrcScroll{
    if (_lrcScroll == nil) {
        _lrcScroll = [[SYGradientView alloc] init];
        _lrcScroll.delegate = self;
        _lrcScroll.contentInset = UIEdgeInsetsMake(edgeInsets, edgeInsets, edgeInsets, edgeInsets);
        _lrcScroll.translatesAutoresizingMaskIntoConstraints = NO;
        _lrcScroll.backgroundColor = [UIColor clearColor];
//        _lrcScroll.alpha = 0.8;
    }
    return _lrcScroll;
}
-(void)setClearMode:(BOOL)clearMode{
    _clearMode = clearMode;
    [self.lrcScroll addMask:_clearMode animateDuration:0.3];
}
-(void)setSong:(SYSong *)song{
    _song = song;
    
    self.lrcView.lrcFile = _song.lrcPath;
    [self.lrcScroll addMask:self.clearMode animateDuration:0.3];
}
-(SYLrcView *)lrcView{
    if (_lrcView == nil) {
        _lrcView = [SYLrcView lrcView];
        _lrcView.delegate = self;
    }
    return _lrcView;
}
#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.lrcDragging = YES;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        float maxBackOffset = self.backgroundScroll.contentSize.height - self.backgroundScroll.frame.size.height;
        float maxLrcOffset = self.lrcScroll.contentSize.height - self.lrcScroll.bounds.size.height;
        
        if ((maxBackOffset > 0) && (maxLrcOffset > 0)) {
            float scrollScale = maxBackOffset / maxLrcOffset;
            float offsetY = self.lrcScroll.contentOffset.y - self.lrcScroll.bounds.size.height * lrcOffset;
            [UIView animateWithDuration:0.3 animations:^{
                self.backgroundScroll.contentOffset = CGPointMake(0, offsetY * scrollScale);
            }];
        }
    });
    
    if (self.lrcDragging) {
        self.lrcView.offset = self.lrcScroll.contentOffset.y;
    }
    
    [self.lrcScroll addMask:self.clearMode animateDuration:0];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.lrcDragging = NO;
}

#pragma mark -  SYLrcDelegate
-(BOOL)lrcViewLineShouldUpdate:(SYLrcView *)lrcView{
    BOOL update = YES;
    if (self.lrcDragging){
        _timeProgressInSecond = self.lrcView.currentTime;
        if ([self.delegate respondsToSelector:@selector(lrcProgressChanged:)]) {
            [self.delegate lrcProgressChanged:self];
        }
    }else{
        self.offset = lrcView.offset;
        self.prevLine = lrcView.prevLine;
        self.playingLine = lrcView.playingLine;
        if ([self.delegate respondsToSelector:@selector(lrcLineShouldUpdate:)]) {
            update = [self.delegate lrcLineShouldUpdate:self];
        }
        if (update) {
            [self nextSentence];
        }
    }
    return update;
}
-(void)lrcViewLineDidUpdate:(SYLrcView *)lrcView{
    
}
-(void)lrcViewLineDidLayoutSubviews:(SYLrcView *)lrcView{
    self.lrcScroll.contentSize = CGSizeMake(0, self.lrcView.bounds.size.height + self.lrcScroll.bounds.size.height);
}
@end
