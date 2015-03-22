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

@end
