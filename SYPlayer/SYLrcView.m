//
//  SYPlayerLrcView.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-22.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//
#warning 用Quartz2D重写单行进度
#import "SYLrcView.h"
#import "NSString+Tools.h"
#import "Gloable.h"
#import "SYGradientView.h"

#define lrcOffset 0.3
#define edgeInsets 10
#define lineMargin 0.5
#define timeOffset -0.1

@interface SYLrcView ()<UIScrollViewDelegate>
/** 用于显示歌词的Scroll */
@property (strong, nonatomic) IBOutlet SYGradientView *lrcScroll;
/** 歌词标题 */
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
/** 文件转为lrc字符串 */
-(NSString *) lrcWithFile:(NSString *)file;
/** 分离时间和歌词 */
-(NSArray*) parseLrcLine:(NSString *)lrcLineText;
/** 时间标签转float */
-(float)timeWithString:(NSString *)string;
/** 歌词排序 */
- (NSArray *)srcObjsBubbleSort:(NSArray *)array;
/** 歌词文本 */
@property (nonatomic,strong) NSArray * lrcLineArray;
/** 时间标签 */
@property (nonatomic,strong) NSArray * lrcTimeArray;
/** LRC Lable */
@property (nonatomic,strong) NSMutableArray * lrcLabelArray;
/** LRC字体 */
@property (nonatomic,strong) UIFont * lrcNextFont;
/** LRC当前字体 */
@property (nonatomic,strong) UIFont * lrcCurrentFont;
/** LRC已过字体 */
@property (nonatomic,strong) UIFont * lrcPastFont;
/** 正在拖动 */
@property (nonatomic,assign) BOOL lrcDragging;
@end

@implementation SYLrcView
//@synthesize backgroundImage = _backgroundImage;
/** 创建新LRC View */
+(instancetype) lrcView
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
    self.lrcNextFont = [UIFont fontWithName:@"Helvetica-ObLique" size:15];
    self.lrcCurrentFont = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    self.lrcPastFont = [UIFont fontWithName:@"Helvetica-ObLique" size:15];//[UIFont fontWithName:@"Helvetica-ObLique" size:14];
    
    self.lrcLabelArray = [NSMutableArray array];
    self.lrcDragging = NO;
    self.lrcFile = nil;
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.lrcScroll];
    {
        NSLayoutConstraint *cnsT = [NSLayoutConstraint constraintWithItem:self.lrcScroll attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *cnsB = [NSLayoutConstraint constraintWithItem:self.lrcScroll attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint *cnsL = [NSLayoutConstraint constraintWithItem:self.lrcScroll attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint *cnsR = [NSLayoutConstraint constraintWithItem:self.lrcScroll attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        [self addConstraints:@[cnsT,cnsB,cnsL,cnsR]];
    }
}

/** 分离时间和歌词 */
-(NSArray*) parseLrcLine:(NSString *)lrcLineText
{
    if ((0 == lrcLineText.length)||(nil == lrcLineText)) {
        return nil;
    }
    NSArray *obj = [lrcLineText componentsSeparatedByString:@"]"];
    NSString *lineStr = obj[1];
    lineStr = [lineStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    lineStr = [lineStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    NSString *timeStr1 = obj[0];
    NSArray *timeObj2 = [timeStr1 componentsSeparatedByString:@"["];
    NSString *timeStr2 = timeObj2[1];
    float time = [self timeWithString:timeStr2] + timeOffset;
    int minute = (int)time / 60;
    float second = time - minute * 60;
    minute %= 60;
    NSString *timeStr = [NSString stringWithFormat:@"%02d:%02d.%02d",minute,(int)second,(int)((second - (int)second) * 100)];
    
    NSString *pStr1 = [timeStr2 substringWithRange:NSMakeRange(2, 1)];
    NSString *pStr2 = [timeStr2 substringWithRange:NSMakeRange(5, 1)];
    if (!((timeStr2.length == 8) && ([pStr1 isEqualToString:@":"]) && ([pStr2 isEqualToString:@"."]))) return nil;
    
    NSArray *retArray = @[timeStr,lineStr];
    return retArray;
}
/** 歌词排序 */
- (NSArray *)srcObjsBubbleSort:(NSMutableArray *)array
{
    int i, y;
    
    for (i = 0; i < [array count] - 1; i++) {
        for (y = (int)[array count] - 1; y > i; y --) {
            NSArray *lrcObjArray = [array objectAtIndex:y];
            NSString *lrcTimeStr = lrcObjArray[0];
            float  num = [self timeWithString:lrcTimeStr];
            
            NSArray *lrcObjArray1 = [array objectAtIndex:y - 1];
            NSString *lrcTimeStr1 = lrcObjArray1[0];
            float  num1 = [self timeWithString:lrcTimeStr1];
            
            if (num < num1) {
                [array exchangeObjectAtIndex:y-1 withObjectAtIndex:y];
            }
        }
    }
    
    return array;
}
/** 时间标签转float */
-(float)timeWithString:(NSString *)string
{
    NSArray *array = [string componentsSeparatedByString:@":"];
    NSString *mStr = array[0];
    NSString *sStr = array[1];
    return [mStr floatValue] * 60 + [sStr floatValue];
}

/** 文件转为lrc字符串 */
-(NSString *)lrcWithFile:(NSString *)file
{
    NSMutableString *lrcString = [NSMutableString string];
    
    return lrcString;
}

-(void)finishProcess:(NSTimer *)timer
{
    NSDictionary *userInfo = timer.userInfo;
    
    NSNumber *nInterval = userInfo[@"interval"];
    float interval = [nInterval floatValue];
    NSString *sentence = userInfo[@"sentence"];
    NSNumber *nCurrentTime = userInfo[@"currentTime"];
    float currentTime = [nCurrentTime floatValue];
    
    [self.delegate lrcView:self sentenceInterval:interval sentence:sentence time:currentTime];
}

/** 跳转到下一句(单句模式需要手动调用) */
-(NSString *)nextSentence:(float)time
{
    UILabel *firstLabel = self.lrcLabelArray[0];
    UILabel *currentLabel;
    NSString *currentLine;
    for (long index = 0; index < self.lrcTimeArray.count; index ++) {
        NSString *str1 = self.lrcTimeArray[index];
        float currentTime = [self timeWithString:str1];
        if (currentTime == time) {
            currentLabel =  self.lrcLabelArray[index];
            currentLine = self.lrcLineArray[index];
        }
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        currentLabel.font = self.lrcCurrentFont;
        currentLabel.textColor = lightGreenColor;
        self.lrcScroll.contentOffset = CGPointMake(-edgeInsets, currentLabel.frame.origin.y - firstLabel.frame.origin.y);
        [self.lrcScroll addMask];
    } completion:^(BOOL finished) {
        
    }];
    
    return currentLine;
}
#pragma mark - Property
/** 设定播放模式 */
-(void)setPlayMode:(lrcPlayMode)playMode
{
    _playMode = playMode;
}
/** 设定播放进度并更新View */
-(void)setTimeProgressInSecond:(float)timeProgressInSecond
{
    _timeProgressInSecond = timeProgressInSecond;
    static float lastSelectTime = 0;
    
    if (!self.lrcDragging) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (long index = 0; index < self.lrcTimeArray.count; index ++) {
                NSString *str1 = self.lrcTimeArray[index];
                float currentTime = [self timeWithString:str1];
                UILabel *currentLabel =  self.lrcLabelArray[index];
                
                float lastTime = currentTime;
                if(index > 0){
                    NSString *str2 = self.lrcTimeArray[index - 1];
                    lastTime = [self timeWithString:str2];
                }
                
                NSString *str3 = self.lrcTimeArray.lastObject;
                float nextTime = [self timeWithString:str3] + defaultInterval;
                UILabel *nextLabel = self.lrcLabelArray.lastObject;
                if (index < self.lrcLabelArray.count - 1) {
                    str3 = self.lrcTimeArray[index + 1];
                    nextTime = [self timeWithString:str3];
                    nextLabel = self.lrcLabelArray[index + 1];
                }
                
                if (self.timeProgressInSecond >= currentTime && self.timeProgressInSecond < nextTime) {//时间在currentTime和nextTime之间
                    if (lastSelectTime != currentTime) {
                        lastSelectTime = currentTime;
                        
                        if (self.playMode == lrcPlayModeWhole) {
                            [self nextSentence:currentTime];
                        }
                        
                        if ((self.playMode == lrcPlayModeSingleSentence) && [self.delegate respondsToSelector:@selector(lrcView:sentenceInterval:sentence:time:)]) {
                            [self nextSentence:lastTime];
                            
                            NSString *sentence = self.lrcLineArray[index];
                            if (index == self.lrcTimeArray.count - 1){
                                nextTime = currentTime;
                            }
                            float interval = nextTime - currentTime;
                            [self.delegate lrcView:self sentenceInterval:interval sentence:sentence time:currentTime];
                        }
                    }
                }
                if (self.timeProgressInSecond < currentTime){//时间未到currentTime
                    currentLabel.font = self.lrcNextFont;
                    currentLabel.textColor = [UIColor whiteColor];
                }
                if (self.timeProgressInSecond > nextTime){//时间已过nextTime
                    currentLabel.font = self.lrcPastFont;
                    currentLabel.textColor = [UIColor whiteColor];
                }
            }
        });
    }
}

/** 设定LRC源文件 */
-(void)setLrcFile:(NSString *)lrcFile
{
    _lrcFile = lrcFile;
    
    if(self.lrcLabelArray.count > 0)[self.lrcLabelArray removeAllObjects];
    for (UIView *label in self.lrcScroll.subviews) {
        if ([label isKindOfClass:[UILabel class]]) {
            [label removeFromSuperview];
        }
    }
    
    if (nil == self.lrcFile) {
        self.titleLabel.text = @"未找到歌词";
    }
    else
    {
        self.titleLabel.text = @"";
        
        NSString * lrcString = [NSString stringWithContentsOfFile:self.lrcFile encoding:NSUTF8StringEncoding error:nil];
        NSArray *lrcFileLineArray = [lrcString componentsSeparatedByString:@"\n"];
        
        NSMutableArray *lrcLineArray = [NSMutableArray array];
        NSMutableArray *lrcTimeArray = [NSMutableArray array];
        for (NSString *lrcLineString in lrcFileLineArray) {
            NSArray *objArray = [self parseLrcLine:lrcLineString];
            if(nil == objArray) continue;
            [lrcTimeArray addObject:objArray[0]];
            [lrcLineArray addObject:objArray[1]];
        }
        
        self.lrcLineArray = [lrcLineArray copy];
        self.lrcTimeArray = [lrcTimeArray copy];
        
        for (int index = 0; index < self.lrcLineArray.count; index ++) {
            NSString *labelText = self.lrcLineArray[index];
            float labelTextH = [labelText sizeWithFont:self.lrcCurrentFont maxSize:CGSizeMake(self.frame.size.width - edgeInsets * 2, 0)].height;
            float labelH = (lineMargin + 1) * labelTextH;
            float labelY = self.lrcScroll.bounds.size.height * lrcOffset;
            if (index > 0) {
                UILabel *lastLabel = self.lrcLabelArray[index - 1];
                labelY = lastLabel.frame.origin.y + lastLabel.frame.size.height;
            }
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, labelY, self.lrcScroll.bounds.size.width - edgeInsets * 2 , labelH)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentLeft;
            label.text = labelText;
            label.font = self.lrcNextFont;
            label.textColor = [UIColor whiteColor];
            
            [self.lrcScroll addSubview:label];
            [self.lrcLabelArray addObject:label];
        }
        
        self.lrcScroll.contentOffset = CGPointMake(-edgeInsets, 0);
        UILabel *lastLabel = self.lrcLabelArray[self.lrcLineArray.count - 1];
        float labelY = lastLabel.frame.origin.y + lastLabel.frame.size.height;
        self.lrcScroll.contentSize = CGSizeMake(0, labelY + self.lrcScroll.bounds.size.height * (1 - lrcOffset));
    }
    [self.lrcScroll addMask];
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

#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.lrcDragging = YES;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static int last_index = 0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        float maxBackOffset = self.backgroundScroll.contentSize.height - self.backgroundScroll.frame.size.height;
        float maxLrcOffset = self.lrcScroll.contentSize.height - self.lrcScroll.bounds.size.height;
        
//        float h1 = self.backgroundScroll.contentSize.height - self.backgroundScroll.frame.size.height * (1 - lrcOffset);
//        float h2 = self.lrcScroll.contentSize.height;
        if ((maxBackOffset > 0) && (maxLrcOffset > 0)) {
            float scrollScale = maxBackOffset / maxLrcOffset;
            float offsetY = self.lrcScroll.contentOffset.y - self.lrcScroll.bounds.size.height * lrcOffset;
            [UIView animateWithDuration:0.3 animations:^{
                self.backgroundScroll.contentOffset = CGPointMake(0, offsetY * scrollScale);
            }];
        }
    });
    
    if (self.lrcDragging) {
        int index = 0;
        float offset = self.lrcScroll.contentOffset.y + self.lrcScroll.frame.size.height * lrcOffset;
        for (int i = 0; i < self.lrcLabelArray.count; i ++) {
            UILabel *label = self.lrcLabelArray[i];
            UILabel *nextLabel = label;
            if (i < self.lrcLabelArray.count - 1) {
                nextLabel = self.lrcLabelArray[i + 1];
            }
            
            if ((offset >= label.frame.origin.y) && (offset <= nextLabel.frame.origin.y)) {
                index = i;
                break;
            }
        }
        
        if (last_index != index) {
            last_index = index;
            
            UILabel *label =  self.lrcLabelArray[index];
            label.font = self.lrcCurrentFont;
            label.textColor = lightGreenColor;
            if (index > 0) {
                UILabel *label =  self.lrcLabelArray[index - 1];
                label.font = self.lrcNextFont;
                label.textColor = [UIColor whiteColor];
            }
            if (index < self.lrcTimeArray.count - 1) {
                UILabel *label =  self.lrcLabelArray[index + 1];
                label.font = self.lrcPastFont;
                label.textColor = [UIColor whiteColor];
            }
            //取出label的time
            NSString *str1 = self.lrcTimeArray[index];
            self.timeProgressInSecond  = [self timeWithString:str1];
            
            if ([self.delegate respondsToSelector:@selector(lrcViewProgressChanged:)]) {
                [self.delegate lrcViewProgressChanged:self];
            }
        }
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.lrcDragging = NO;
}
@end
