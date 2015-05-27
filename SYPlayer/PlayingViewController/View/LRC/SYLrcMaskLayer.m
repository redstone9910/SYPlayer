//
//  SYLrcMaskLayer.m
//  SYPlayer
//
//  Created by YinYanhui on 15-5-19.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYLrcMaskLayer.h"

@implementation SYLrcMaskLayer

- (void)drawInContext:(CGContextRef)context{
//    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
//
//    // MARK: circlePath
//    [path appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2, 200) radius:100 startAngle:0 endAngle:2*M_PI clockwise:NO]];
//
//    self.path = path.CGPath;
//    CGContextSetRGBFillColor(context, 1, 0, 0, 1);
//    return;
    
    CGFloat colors [] = {
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, self.maxAlpha,
        0.0, 0.0, 0.0, 0.0,
    };
    CGFloat locations[] = {
        0.0f,0.3f,1.0f
    };
    
    self.backgroundColor = [UIColor clearColor].CGColor;
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, locations, sizeof(colors)/(sizeof(colors[0])*4));
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    CGRect aRect = {self.bounds.origin,self.bounds.size};//CGRectInset(CGContextGetClipBoundingBox(context), 50.0f, 20.0f);
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

-(void)setMaxAlpha:(float)maxAlpha{
    _maxAlpha = maxAlpha;
    if (_maxAlpha > 1) {
        _maxAlpha = 1;
    }else if (_maxAlpha < 0){
        _maxAlpha = 0;
    }
    [self setNeedsDisplay];
}
@end
