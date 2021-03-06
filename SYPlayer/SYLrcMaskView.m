//
//  SYLrcMaskView.m
//  SYPlayer
//
//  Created by YinYanhui on 15-5-19.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYLrcMaskView.h"

@implementation SYLrcMaskView
-(void)drawRect:(CGRect)rect{
    CGFloat colors [] = {
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 0.0, 0.0,
    };
    CGFloat locations[] = {
        0.0f,0.3f,1.0f
    };
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, locations, sizeof(colors)/(sizeof(colors[0])*4));
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect aRect = rect;//CGRectInset(CGContextGetClipBoundingBox(context), 50.0f, 20.0f);
    CGContextSaveGState(context);                // SaveGState
    CGContextClipToRect(context, aRect);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(aRect), CGRectGetMinY(aRect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(aRect), CGRectGetMaxY(aRect));
    
    // kCGGradientDrawsBeforeStartLocation    开始位置之外的也画
    // kCGGradientDrawsAfterEndLocation        结束位置之外的也画
    // 0                                    正常状态
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    
    CGContextRestoreGState(context);            // RestoreGState
    CGContextDrawPath(context, kCGPathStroke);
}
@end
