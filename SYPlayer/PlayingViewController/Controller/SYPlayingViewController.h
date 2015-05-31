//
//  SYPlayingViewController.h
//  SYPlayer
//
//  Created by YinYanhui on 15-3-21.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYAlbum;
@class SYAuthor;
@class FSStreamConfiguration;

@interface SYPlayingViewController : UIViewController
@property (nonatomic,strong) FSStreamConfiguration * configuration;
@end
