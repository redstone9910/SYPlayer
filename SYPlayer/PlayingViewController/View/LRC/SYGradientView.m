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

#define kMaxAlphaClear 0.1
#define kMaxAlphaOpaque 1

@interface SYGradientView()
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic,assign) BOOL clearMode;
@property (nonatomic,strong) SYLrcMaskLayer *maskLayer;
@property (nonatomic,assign) float duration;
@end

@implementation SYGradientView

- (void)addMask:(BOOL)clearMode animateDuration:(float)duration{
//    CGRect frame = {self.contentOffset.x,self.contentOffset.y,self.bounds.size};
//    SYLrcMaskView *maskView = [[SYLrcMaskView alloc] initWithFrame:frame];
//    maskView.backgroundColor = [UIColor clearColor];
//    [maskView setNeedsDisplay];
//    self.maskView = maskView;
    
    self.maskLayer.frame = self.layer.bounds;
    self.clearMode = clearMode;
    self.duration = duration;
    
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)update{
    if (self.duration < self.link.duration) {
        self.duration = self.link.duration;
    }
    float step = (self.link.duration / self.duration) * (kMaxAlphaOpaque - kMaxAlphaClear);
    
    if (self.clearMode) {
        if (self.maskLayer.maxAlpha > kMaxAlphaClear) {
            self.maskLayer.maxAlpha -= step;
        }else{
            [self.link invalidate];
            self.link = nil;
        }
    }else{
        if (self.maskLayer.maxAlpha < kMaxAlphaOpaque) {
            self.maskLayer.maxAlpha += step;
        }else{
            [self.link invalidate];
            self.link = nil;
        }
    }
    self.layer.mask = self.maskLayer;
}

- (CADisplayLink *)link
{
    if (_link == nil) {
        self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    }
    return _link;
}
-(SYLrcMaskLayer *)maskLayer{
    if (_maskLayer == nil) {
        _maskLayer = [[SYLrcMaskLayer alloc] init];
    }
    return _maskLayer;
}
@end
