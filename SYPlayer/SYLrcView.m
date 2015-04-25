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

#define lrcOffset 0.3
#define edgeInsets 10
#define lineMargin 5
#define defaultInterval 5//默认每句5秒

@interface SYLrcView ()<UIScrollViewDelegate>
/** 背景图片Scroll */
@property (weak, nonatomic) IBOutlet UIScrollView *backgroundScroll;
/** 用于显示歌词的Scroll */
@property (weak, nonatomic) IBOutlet UIScrollView *lrcScroll;
/** 歌词标题 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
/** 背景图片 */
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
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
@property (nonatomic,strong) NSMutableArray * lrcLableArray;
/** LRC字体 */
@property (nonatomic,strong) UIFont * lrcFont;
/** LRC当前字体 */
@property (nonatomic,strong) UIFont * lrcCurrentFont;
/** LRC已过字体 */
@property (nonatomic,strong) UIFont * lrcPasteFont;
/** 正在拖动 */
@property (nonatomic,assign,getter = isDragging) BOOL dragging;
@end

@implementation SYLrcView

/** 创建新LRC View */
+(instancetype) lrcView
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSArray *objs = [bundle loadNibNamed:NSStringFromClass(self) owner:nil options:nil];
    SYLrcView *lrcview = [objs lastObject];
    
    return lrcview;
}

-(void)awakeFromNib
{
    self.lrcFont = [UIFont systemFontOfSize:14.0f];
    self.lrcCurrentFont = [UIFont fontWithName:@"Helvetica-BoldObLique" size:15];
    self.lrcPasteFont = [UIFont fontWithName:@"Helvetica-ObLique" size:14];
    
    self.lrcScroll.delegate = self;
    self.lrcScroll.contentInset = UIEdgeInsetsMake(edgeInsets, edgeInsets, edgeInsets, edgeInsets);
    
    self.lrcLableArray = [NSMutableArray array];
    self.dragging = NO;
    self.backgroundScroll.contentSize = self.backgroundImageView.image.size;
}

/** 重新布局时调用 */
-(void)layoutSubviews
{
    [super layoutSubviews];
}
/** 分离时间和歌词 */
-(NSArray*) parseLrcLine:(NSString *)lrcLineText
{
    if ((0 == lrcLineText.length)||(nil == lrcLineText)) {
        return nil;
    }
//    NSArray *obj1 = [lrcLineText componentsSeparatedByString:@"\n"];
    NSArray *obj = [lrcLineText componentsSeparatedByString:@"]"];
    
    NSString *timeStr1 = obj[0];
    NSArray *timeObj2 = [timeStr1 componentsSeparatedByString:@"["];
    NSString *timeStr2 = timeObj2[1];
    
    NSString *pStr1 = [timeStr2 substringWithRange:NSMakeRange(2, 1)];
    NSString *pStr2 = [timeStr2 substringWithRange:NSMakeRange(5, 1)];
    if (!((timeStr2.length == 8) && ([pStr1 isEqualToString:@":"]) && ([pStr2 isEqualToString:@"."]))) return nil;
    
    NSArray *retArray = @[timeStr2,obj[1]];
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
-(void)sendTimerDelegate:(NSTimer *)timer
{
    NSNumber *num = timer.userInfo;
    float interval = [num floatValue];
    [self.delegate lrcView:self SentenceInterval:interval];
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
    static float lastTime = 0;
    
    if (!self.isDragging) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (long index = self.lrcTimeArray.count - 1; index > -1; index --) {
                NSString *str1 = self.lrcTimeArray[index];
                float time1 = [self timeWithString:str1];
                
                if (timeProgressInSecond >= time1) {
                    UILabel *label0 =  [self.lrcLableArray firstObject];
                    UILabel *label =  self.lrcLableArray[index];
                    label.font = self.lrcCurrentFont;
                    
                    if (index > 0) {
                        for (long i = index; i > 0; i --) {
                            UILabel *label =  self.lrcLableArray[i - 1];
                            label.font = self.lrcPasteFont;
                        }
                    }
                    if (index < self.lrcTimeArray.count - 1) {
                        for (long i = index; i < self.lrcTimeArray.count - 1; i ++) {
                            UILabel *label =  self.lrcLableArray[i + 1];
                            label.font = self.lrcFont;
                        }
                    }
                    
                    if (lastTime != time1) {
                        lastTime = time1;
                        
                        self.lrcScroll.contentOffset = CGPointMake(-edgeInsets, label.frame.origin.y - label0.frame.origin.y);
                        if (self.playMode == lrcPlayModeSingleSentence) {
                            if ([self.delegate respondsToSelector:@selector(lrcView:SentenceInterval:)]) {
                                float interval;
                                if (index > 0) {
                                    interval = time1 - [self timeWithString:self.lrcTimeArray[index - 1]];
                                } else {
                                    interval = defaultInterval;
                                }
                                
                                [self.delegate lrcView:self SentenceInterval:interval];
                                if (index == self.lrcTimeArray.count - 1) {
                                    [NSTimer scheduledTimerWithTimeInterval:defaultInterval target:self selector:@selector(sendTimerDelegate:) userInfo:[NSNumber numberWithFloat:defaultInterval] repeats:NO];
                                }
                            }
                        }
                    }
                    break;
                }
            }
        });
    }
}

/** 设定并更新背景图片 */
-(void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    
    self.backgroundImageView.image = self.backgroundImage;
}

/** 设定LRC源文件 */
-(void)setLrcFile:(NSString *)lrcFile
{
    _lrcFile = lrcFile;
    
    if(self.lrcLableArray.count > 0)[self.lrcLableArray removeAllObjects];
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
            float labelTextH = [labelText sizeWithFont:self.lrcFont maxSize:CGSizeMake(self.frame.size.width - edgeInsets * 2, 0)].height;
            float labelH = lineMargin + labelTextH;
            float labelY = self.lrcScroll.bounds.size.height * lrcOffset;
            if (index > 0) {
                UILabel *lastLabel = self.lrcLableArray[index - 1];
                labelY = lastLabel.frame.origin.y + lastLabel.frame.size.height;
            }
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, labelY, self.lrcScroll.bounds.size.width - edgeInsets * 2 , labelH)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentLeft;
            label.text = labelText;
            label.font = self.lrcFont;
            
            [self.lrcScroll addSubview:label];
            [self.lrcLableArray addObject:label];
        }
        
        self.lrcScroll.contentOffset = CGPointMake(-edgeInsets, 0);
        UILabel *lastLabel = self.lrcLableArray[self.lrcLineArray.count - 1];
        float labelY = lastLabel.frame.origin.y + lastLabel.frame.size.height;
        self.lrcScroll.contentSize = CGSizeMake(0, labelY + self.lrcScroll.bounds.size.height * (1 - lrcOffset));
    }
}
#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.dragging = YES;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static int last_index = 0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        float h1 = self.backgroundScroll.contentSize.height - self.backgroundScroll.frame.size.height * (1 - lrcOffset);
        float h2 = self.lrcScroll.contentSize.height;
        if (h2) {
            float scrollScale = h1 / h2;
            float offsetY = self.lrcScroll.contentOffset.y;
            self.backgroundScroll.contentOffset = CGPointMake(0, offsetY * scrollScale);
        }
    });
    
    if (self.isDragging) {
        int index = 0;
        float offset = self.lrcScroll.contentOffset.y + self.lrcScroll.frame.size.height * lrcOffset;
        for (int i = 0; i < self.lrcLableArray.count; i ++) {
            UILabel *label = self.lrcLableArray[i];
            UILabel *nextLabel = label;
            if (i < self.lrcLableArray.count - 1) {
                nextLabel = self.lrcLableArray[i + 1];
            }
            
            if ((offset >= label.frame.origin.y) && (offset <= nextLabel.frame.origin.y)) {
                index = i;
                break;
            }
        }
        
        if (last_index != index) {
            last_index = index;
            
            UILabel *label =  self.lrcLableArray[index];
            label.font = self.lrcCurrentFont;
            if (index > 0) {
                UILabel *label =  self.lrcLableArray[index - 1];
                label.font = self.lrcPasteFont;
            }
            if (index < self.lrcTimeArray.count - 1) {
                UILabel *label =  self.lrcLableArray[index + 1];
                label.font = self.lrcFont;
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
    self.dragging = NO;
}
@end
