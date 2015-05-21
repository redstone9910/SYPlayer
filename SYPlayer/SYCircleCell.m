//
//  VolumeButtonCell.m
//  SYPlayer
//
//  Created by YinYanhui on 15-5-7.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYCircleCell.h"
#import "DKCircleButton.h"
#import "SYCircleModel.h"
#import "Gloable.h"

#define centerMargin 5
#define bottomLabelFontSize 0.18
#define buttonLabelFontSize 0.5

@interface SYCircleCell()
@property DKCircleButton *centerButton;
@property (nonatomic,strong) UILabel * centerLabel;
@end

@implementation SYCircleCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self internalInit];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    [self internalInit];
    return self;
}
-(void)internalInit{
    self.defaultColor = lightGreenColor;
    self.titleFontSize = bottomLabelFontSize;
    
    /** centerLabel约束关系 */
    self.centerLabel = [[UILabel alloc] init];
    self.centerLabel.textColor = self.defaultColor;
//    self.centerLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:self.centerLabel];
    self.centerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *cnsB2 = [NSLayoutConstraint constraintWithItem:self.centerLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *cnsL2 = [NSLayoutConstraint constraintWithItem:self.centerLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *cnsR2 = [NSLayoutConstraint constraintWithItem:self.centerLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    [self.contentView addConstraints:@[cnsB2,cnsL2,cnsR2]];
    self.centerLabel.numberOfLines = 1;
    self.centerLabel.textAlignment = NSTextAlignmentCenter;
    
    /** centerButton约束关系 */
    self.centerButton = [[DKCircleButton alloc] init];
    self.centerButton.borderColor = self.defaultColor;
    [self.centerButton setTitleColor:self.defaultColor forState:UIControlStateNormal];
    [self.centerButton addTarget:self action:@selector(buttonDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.centerButton];
    self.centerButton.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *cnsT1 = [NSLayoutConstraint constraintWithItem:self.centerButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *cnsCX1 = [NSLayoutConstraint constraintWithItem:self.centerButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *cnsW1 = [NSLayoutConstraint constraintWithItem:self.centerButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    NSLayoutConstraint *cnsB1 = [NSLayoutConstraint constraintWithItem:self.centerButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.centerLabel attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    cnsB1.priority = 750;
    
    [self.contentView addConstraints:@[cnsT1,cnsCX1,cnsB1,cnsW1]];
    NSLayoutConstraint *cnsRe1 = [NSLayoutConstraint constraintWithItem:self.centerButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.centerButton attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    [self.centerButton addConstraints:@[cnsRe1]];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    //    NSLog(@"%@,%@",NSStringFromCGRect(self.contentView.bounds),NSStringFromCGRect(self.centerButton.bounds));
//    NSArray *fontArray = [UIFont familyNames];
//    fontArray = [fontArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        NSString *str1 = obj1;
//        NSString *str2 = obj2;
//        
//        char c1 = [str1 characterAtIndex:0];
//        char c2 = [str2 characterAtIndex:0];
//        if (c1 < c2) {
//            return NSOrderedAscending;
//        }else{
//            return NSOrderedDescending;
//        }
//    }];
//    [fontArray writeToFile:[catchePath stringByAppendingPathComponent:@"font.plist"] atomically:YES];
    
    self.centerLabel.font = [UIFont fontWithName:@"Iowan Old Style" size:self.contentView.bounds.size.height * self.titleFontSize];
    self.centerButton.titleLabel.font = [UIFont fontWithName:@"Iowan Old Style" size:self.contentView.bounds.size.height * buttonLabelFontSize];
}
#pragma mark - property
-(void)setModel:(SYCircleModel *)model{
    _model = model;
    
    [self.centerButton setTitle:self.model.buttonTitle forState:UIControlStateNormal];
    self.centerLabel.text = self.model.bottomTitle;
}
-(void)setDefaultColor:(UIColor *)defaultColor{
    _defaultColor = defaultColor;
    
    self.centerButton.borderColor = self.defaultColor;
    [self.centerButton setTitleColor:self.defaultColor forState:UIControlStateNormal];
    self.centerLabel.textColor = self.defaultColor;
}
-(void)setTitleFontSize:(float)titleFontSize{
    _titleFontSize = titleFontSize;
    self.centerLabel.font = [UIFont fontWithName:@"Iowan Old Style" size:self.contentView.bounds.size.height * self.titleFontSize];
}
#pragma mark - private
-(void)buttonDidClick{
    if ([self.delegate respondsToSelector:@selector(circleCellDidClick:)]) {
        [self.delegate circleCellDidClick:self];
    }
}
@end
