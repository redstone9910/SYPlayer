//
//  NSString+Tools.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-21.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "NSString+Tools.h"

@implementation NSString (Tools)

/**
 *  计算文字尺寸
 *
 *  @param text    需要计算尺寸的文字
 *  @param font    文字的字体
 *  @param maxSize 文字的最大尺寸
 */
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

/** 时间转换为字符串 mm:ss */
+(NSString *)stringFromTime:(int)time
{
    NSMutableString *string = [NSMutableString string];
    if (time < 0) {
        [string appendString:@"-"];
    }
    
    NSString *minute = [NSString stringWithFormat:@"%02d",(time / 60) % 100];
    NSString *second = [NSString stringWithFormat:@"%02d",time % 60];
    [string appendString:minute];
    [string appendString:@":"];
    [string appendString:second];
    return string;
}

/** 求字体高度 */
+(float)heightWithFont:(UIFont *)font
{
    return [@"A" sizeWithFont:font maxSize:CGSizeMake(0, 0)].height;
}

@end
