//
//  SYPlayingViewController.h
//  SYPlayer
//
//  Created by YinYanhui on 15-3-21.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYPlayListModel.h"
@class FSStreamConfiguration;

@interface SYPlayingViewController : UIViewController
@property (nonatomic,strong) SYPlayListModel * playListModel;
@property (nonatomic,strong) FSStreamConfiguration * configuration;
@end
