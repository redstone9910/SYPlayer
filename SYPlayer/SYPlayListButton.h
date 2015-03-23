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
/** 代理 */
@property (nonatomic,strong) id<SYPlayListButtonDelegate> delegate;
/** 是否已展开 */
@property (nonatomic,assign,getter=isOpened) BOOL Opened;
/** 通过标题创建新对象 */
+(instancetype) playListButtonWithString:(NSString *) titleString;
/** 创建新对象 */
+(instancetype) playListButton;
@property (nonatomic,copy) NSString * titleText;
@end
