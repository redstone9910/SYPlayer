//
//  SYGradientView.m
//  SYPlayer
//
//  Created by YinYanhui on 15-5-18.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYGradientView.h"
#import "SYLrcMaskView.h"
#import "SYLrcMaskLayer.h"
#include "Gloable.h"
@interface SYGradientView()


@end

@implementation SYGradientView

- (void)addMask{
//    CGRect frame = {self.contentOffset.x,self.contentOffset.y,self.bounds.size};
//    SYLrcMaskView *maskView = [[SYLrcMaskView alloc] initWithFrame:frame];
//    maskView.backgroundColor = [UIColor clearColor];
//    [maskView setNeedsDisplay];
//    self.maskView = maskView;
    
    CGRect frame = self.layer.bounds;
    SYLrcMaskLayer *maskLayer = [[SYLrcMaskLayer alloc] init];
    maskLayer.frame = self.layer.bounds;
    [maskLayer setNeedsDisplay];
    self.layer.mask = maskLayer;
}
@end
