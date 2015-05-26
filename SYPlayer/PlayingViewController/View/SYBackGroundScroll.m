//
//  SYBackGroundScroll.m
//  SYPlayer
//
//  Created by YinYanhui on 15-5-20.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYBackGroundScroll.h"
#import "UIImage+REFrostedViewController.h"
#import "Gloable.h"
@interface SYBackGroundScroll()
/** 背景图片 */
@property (strong, nonatomic) UIImageView *backgroundImageView;
/** 黑色背景 */
@property (nonatomic,strong) UIView * gradientView;
@end
@implementation SYBackGroundScroll
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self customInit];
    }
    return self;
}
-(void)customInit{
    [self addSubview:self.backgroundImageView];
    {
        NSLayoutConstraint *cnsR = [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeHeight multiplier:640.0 / 1138 constant:0];
        [self.backgroundImageView addConstraints:@[cnsR]];
    }
    {
        NSLayoutConstraint *cnsW = [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        NSLayoutConstraint *cnsT = [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *cnsCX = [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        [self addConstraints:@[cnsW,cnsCX,cnsT]];
    }
    
    [self.backgroundImageView addSubview:self.gradientView];
    {
        NSLayoutConstraint *cnsT = [NSLayoutConstraint constraintWithItem:self.gradientView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *cnsB = [NSLayoutConstraint constraintWithItem:self.gradientView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint *cnsL = [NSLayoutConstraint constraintWithItem:self.gradientView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint *cnsR = [NSLayoutConstraint constraintWithItem:self.gradientView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        [self.backgroundImageView addConstraints:@[cnsT,cnsB,cnsL,cnsR]];
    }
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.contentSize = self.backgroundImage.size;
}
/** 懒加载背景 */
-(UIImageView *)backgroundImageView{
    if (_backgroundImageView == nil) {
        _backgroundImageView = [[UIImageView alloc] init];
        self.backgroundImage = [UIImage imageNamed:@"girl"];
        _backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _backgroundImageView;
}
/** 设定并更新背景图片 */
-(void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = [backgroundImage re_applyBlurWithRadius:6 tintColor:[UIColor clearColor] saturationDeltaFactor:1.8 maskImage:nil];
    
    self.backgroundImageView.image = self.backgroundImage;
}
/** 黑色背景 */
-(UIView *)gradientView{
    if (_gradientView == nil) {
        _gradientView = [[UIView alloc] init];
        _gradientView.translatesAutoresizingMaskIntoConstraints = NO;
        _gradientView.userInteractionEnabled = NO;
        _gradientView.backgroundColor = [UIColor blackColor];
        _gradientView.alpha = 0.6;
    }
    return _gradientView;
}
@end
