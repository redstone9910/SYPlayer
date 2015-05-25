//
//  SYRootViewController.h
//  SYPlayer
//
//  Created by YinYanhui on 15-3-20.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYPlaylists;
@interface SYRootViewController : UIViewController
/** 顶部背景图 */
@property (nonatomic,strong) UIImageView * backBg;
@property (nonatomic,strong) SYPlaylists *volumes;
@end
