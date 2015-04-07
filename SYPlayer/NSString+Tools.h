//
//  NSString+Tools.h
//  SYPlayer
//
//  Created by YinYanhui on 15-3-21.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Tools)

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;
+(NSString *)stringFromTime:(int) time;
+(float)heightWithFont:(UIFont *)font;

- (NSString *)myMD5;

/**
 *  32位MD5加密
 *
 *  @return 32位MD5加密结果
 */
- (NSString *)MD5;

/**
 *  SHA1加密
 *
 *  @return SHA1加密结果
 */
- (NSString *)SHA1;

@end
