//
//  SYPlayListButton.h
//  SYPlayer
//
//  Created by YinYanhui on 15-3-21.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYPlayListButton;

@protocol SYPlayListButtonDelegate <NSObject>
@required
-(void) playListButtonBtnClicked:(SYPlayListButton *) playListBtn;
@end

@interface SYPlayListButton : UIView

@property (nonatomic,strong) id<SYPlayListButtonDelegate> delegate;

+(instancetype) playListButtonWithString:(NSString *) titleString;
+(instancetype) playListButton;
@end
