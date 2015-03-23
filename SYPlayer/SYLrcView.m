//
//  SYPlayerLrcView.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-22.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//
#warning 1.滑动时自动左移10 2.滑动过快时不能刷新全部行字体
#import "SYLrcView.h"
#import "NSString+Tools.h"

#define LRCOFFSET 0.3

@interface SYLrcView ()<UIScrollViewDelegate>

/** 用于显示歌词的Scroll */
@property (weak, nonatomic) IBOutlet UIScrollView *lrcScroll;
/** 歌词标题 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

-(NSString *) lrcWithFile:(NSString *)file;
-(NSArray*) parseLrcLine:(NSString *)lrcLineText;
-(float)timeWithString:(NSString *)string;
/** 歌词排序 */
- (NSArray *)srcObjsBubbleSort:(NSArray *)array;
/** 0:时间标签 1:歌词 */
@property (nonatomic,strong) NSArray * lrcLineArray;
/** 存储LRC Lable */
@property (nonatomic,strong) NSMutableArray * lrcLableArray;
/** LRC字体 */
@property (nonatomic,strong) UIFont * lrcFont;
/** LRC当前字体 */
@property (nonatomic,strong) UIFont * lrcCurrentFont;
/** LRC已过字体 */
@property (nonatomic,strong) UIFont * lrcPasteFont;

@property (nonatomic,assign,getter = isDragging) BOOL dragging;
@end

@implementation SYLrcView
/** 创建新LRC View并设定LRC文件 */
+(instancetype) lrcViewWithFrame:(CGRect)frame withLrcFile:(NSString *)file
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSArray *objs = [bundle loadNibNamed:NSStringFromClass(self) owner:nil options:nil];
    
    SYLrcView *lrcview = [objs lastObject];
    
    lrcview.frame = frame;
    lrcview.lrcFont = [UIFont systemFontOfSize:14.0f];
    lrcview.lrcCurrentFont = [UIFont fontWithName:@"Helvetica-BoldObLique" size:15];
    lrcview.lrcPasteFont = [UIFont fontWithName:@"Helvetica-ObLique" size:14];
    
    lrcview.lrcScroll.delegate = lrcview;
    lrcview.lrcLableArray = [NSMutableArray array];
    
    lrcview.dragging = NO;
    
    lrcview.lrcFile = file;
    return lrcview;
}

/** 设定播放进度并更新View */
-(void)setTimeProgressInSecond:(float)timeProgressInSecond
{
    _timeProgressInSecond = timeProgressInSecond;
#warning 歌词同步差一行
    if (!self.isDragging) {
        for (int index = self.lrcLineArray.count - 1; index > 0; index --) {
            NSArray *ary1 = self.lrcLineArray[index];
            NSString *str1 = ary1[0];
            float time1 = [self timeWithString:str1];
            
            float lableH = [NSString heightWithFont:self.lrcFont] + 10;
            if (timeProgressInSecond > time1) {
                self.lrcScroll.contentOffset = CGPointMake(0, index * lableH);
                
                UILabel *lable =  self.lrcLableArray[index];
                lable.font = self.lrcCurrentFont;
                if (index > 0) {
                    UILabel *lable =  self.lrcLableArray[index - 1];
                    lable.font = self.lrcPasteFont;
                }
                if (index < self.lrcLineArray.count - 1) {
                    UILabel *lable =  self.lrcLableArray[index + 1];
                    lable.font = self.lrcFont;
                }
                
                break;
            }
        }
    }
}

/** 设定并更新背景图片 */
-(void)setBackgroundImage:(UIImage *)backgroundImage
{
    
}

/** 设定LRC源文件 */
-(void)setLrcFile:(NSString *)lrcFile
{
    _lrcFile = lrcFile;
    
    if(self.lrcLableArray.count > 0)[self.lrcLableArray removeAllObjects];
    
    if (nil == self.lrcFile) {
        self.titleLabel.text = @"未找到歌词";
    }
    else
    {
        self.titleLabel.text = @"";
        
        NSString * lrcString = [NSString stringWithContentsOfFile:self.lrcFile encoding:NSUTF8StringEncoding error:nil];
        NSArray *lrcFileLineArray = [lrcString componentsSeparatedByString:@"\n"];
        
        NSMutableArray *objsArray = [NSMutableArray array];
        for (NSString *lrcLineString in lrcFileLineArray) {
            NSArray *objArray = [self parseLrcLine:lrcLineString];
            if(nil == objArray) continue;
            [objsArray addObject:objArray];
        }
        
        self.lrcLineArray = objsArray;
        float lableH = [NSString heightWithFont:self.lrcFont] + 10;
        self.lrcScroll.contentOffset = CGPointMake(0, 0);
        self.lrcScroll.contentSize = CGSizeMake(0, self.lrcLineArray.count * lableH + self.lrcScroll.bounds.size.height);
        
        for (int index = 0; index < self.lrcLineArray.count; index ++) {
            NSArray *timelrc = self.lrcLineArray[index];
            
            UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, self.lrcScroll.bounds.size.height * LRCOFFSET  + index * lableH,self.lrcScroll.bounds.size.width , lableH)];
            lable.text = timelrc[1];
            lable.textAlignment = NSTextAlignmentCenter;
            lable.font = self.lrcFont;
            
            [self.lrcScroll addSubview:lable];
            [self.lrcLableArray addObject:lable];
        }
    }
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
    return [mStr floatValue] + [sStr floatValue];
}
///** 设定并更新LRC字体 */
//-(void)setLrcFont:(UIFont *)lrcFont
//{
//    _lrcFont = lrcFont;
//}
/** 重新布局时调用 */
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.lrcScroll.frame = self.frame;
    self.lrcScroll.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
}
/** 文件转为lrc字符串 */
-(NSString *)lrcWithFile:(NSString *)file
{
    NSMutableString *lrcString = [NSMutableString string];
    
    return lrcString;
}

#pragma - UIScrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.dragging = YES;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static int last_index = 0;
    
    if (self.isDragging) {
        float lableH = [NSString heightWithFont:self.lrcFont] + 10;
        //取出对应位置的label并设定字体
        int index = self.lrcScroll.contentOffset.y / lableH;
        if(index > self.lrcLineArray.count - 1) index = (int)(self.lrcLineArray.count - 1);
        
        if (last_index != index) {
            last_index = index;
            
            UILabel *lable =  self.lrcLableArray[index];
            lable.font = self.lrcCurrentFont;
            if (index > 0) {
                UILabel *lable =  self.lrcLableArray[index - 1];
                lable.font = self.lrcPasteFont;
            }
            if (index < self.lrcLineArray.count - 1) {
                UILabel *lable =  self.lrcLableArray[index + 1];
                lable.font = self.lrcFont;
            }
            //取出label的time
            NSArray *ary1 = self.lrcLineArray[index];
            NSString *str1 = ary1[0];
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
