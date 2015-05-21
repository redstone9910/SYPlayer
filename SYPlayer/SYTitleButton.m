//
//  SYTitleButton.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-21.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYTitleButton.h"
#import "NSString+Tools.h"
#import "Gloable.h"

@interface SYTitleButton()
@property (strong, nonatomic) UIButton *titleBtn;
@property (strong, nonatomic) UIImageView *titleArrow;
@property (nonatomic,strong) UILabel * titleLabel;
@end

@implementation SYTitleButton

+(instancetype) playListButton
{
    return [[self alloc] init];
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self costumInit];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self costumInit];
    }
    return self;
}
-(void)costumInit{
    self.backgroundColor = [UIColor clearColor];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.titleLabel];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    {
        
        NSLayoutConstraint *cnsX1 = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *cnsY1 = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [self addConstraints:@[cnsX1,cnsY1]];
    }
    
    self.titleArrow.backgroundColor = [UIColor clearColor];
    [self addSubview:self.titleArrow];
    self.titleArrow.translatesAutoresizingMaskIntoConstraints = NO;
    {
        NSLayoutConstraint *cnsT = [NSLayoutConstraint constraintWithItem:self.titleArrow attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *cnsB = [NSLayoutConstraint constraintWithItem:self.titleArrow attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint *cnsL = [NSLayoutConstraint constraintWithItem:self.titleArrow attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        [self addConstraints:@[cnsT,cnsB,cnsL]];
        
        NSLayoutConstraint *cnsRe = [NSLayoutConstraint constraintWithItem:self.titleArrow attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.titleArrow attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
        [self.titleArrow addConstraints:@[cnsRe]];
    }
    
    self.titleBtn.backgroundColor = [UIColor clearColor];
    self.titleBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.titleBtn];
    {
        NSLayoutConstraint *cnsT3 = [NSLayoutConstraint constraintWithItem:self.titleBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *cnsB3 = [NSLayoutConstraint constraintWithItem:self.titleBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint *cnsL3 = [NSLayoutConstraint constraintWithItem:self.titleBtn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint *cnsR3 = [NSLayoutConstraint constraintWithItem:self.titleBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        [self addConstraints:@[cnsT3,cnsB3,cnsL3,cnsR3]];
    }
}

/** 点击下拉列表 */
- (void)listBtnClick{
    self.Opened = !self.isOpened;
}

#pragma mark - property
/** 展开/关闭 */
-(void)setOpened:(BOOL)Opened
{
    _Opened = Opened;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.titleArrow.layer.transform = CATransform3DMakeRotation((self.isOpened ? 179.9 : 0) * M_PI / 180, 0, 0, 1);
//        self.titleArrow.transform = CGAffineTransformMakeRotation((self.isOpened ? 179.9 : 0) * M_PI / 180);
    }];
    
    if ([self.delegate respondsToSelector:@selector(playListButtonBtnClicked:)]) {
        [self.delegate playListButtonBtnClicked:self];
    }
}

/** 设定标题 */
-(void)setTitleText:(NSString *)titleText
{
    _titleText = titleText;
    
    self.titleLabel.text = titleText;
}

-(UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
    }
    return _titleLabel;
}

-(UIImageView *)titleArrow{
    if (_titleArrow == nil) {
        _titleArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigationbar_arrow_down"]];
        _titleArrow.contentMode = UIViewContentModeCenter;
    }
    return _titleArrow;
}

-(UIButton *)titleBtn{
    if (_titleBtn == nil) {
        _titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_titleBtn addTarget:self action:@selector(listBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _titleBtn;
}
@end
