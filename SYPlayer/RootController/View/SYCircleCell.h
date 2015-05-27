//
//  VolumeButtonCell.h
//  SYPlayer
//
//  Created by YinYanhui on 15-5-7.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYCircleModel;
@class SYCircleCell;

@protocol SYCircleCellDelegate <NSObject>
@optional
-(void)circleCellDidClick:(SYCircleCell *)cell;
@end

@interface SYCircleCell : UICollectionViewCell
@property (nonatomic,strong) SYCircleModel * model;
@property (nonatomic,weak) id<SYCircleCellDelegate> delegate;
@property (nonatomic,strong,readwrite) UIColor * defaultColor;
@property (nonatomic,assign) float titleFontSize;
@end
