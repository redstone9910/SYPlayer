//
//  SYPlayerLrcView.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-22.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYLrcView.h"

@implementation SYLrcView
/** 创建新LRC View并设定LRC文件 */
+(instancetype)lrcViewWithLrcFile:(NSString *)file
{
    SYLrcView *lrc =  [[self alloc] init];
    lrc.lrcFile = file;
    return lrc;
}

/** 设定播放进度并更新View */
-(void)setTimeProgressInSecond:(int)timeProgressInSecond
{
    _timeProgressInSecond = timeProgressInSecond;
}

/** 设定并更新背景图片 */
-(void)setBackgroundImage:(UIImage *)backgroundImage
{
    
}

/** 设定LRC源文件 */
-(void)setLrcFile:(NSString *)lrcFile
{
    
}

/** 设定并更新LRC字体 */
-(void)setLrcFont:(UIFont *)lrcFont
{
    
}
@end
