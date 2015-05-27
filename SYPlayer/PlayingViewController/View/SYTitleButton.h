//
//  SYTitleButton.h
//  SYPlayer
//
//  Created by YinYanhui on 15-3-21.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYTitleButton;

@protocol SYTitleButtonDelegate <NSObject>
@required
-(void) playListButtonBtnClicked:(SYTitleButton *) playListBtn;
@end

@interface SYTitleButton : UIView
/** 代理 */
@property (nonatomic,weak) id<SYTitleButtonDelegate> delegate;
/** 是否已展开 */
@property (nonatomic,assign,getter=isOpened) BOOL Opened;
/** 创建新对象 */
+(instancetype) playListButton;
@property (nonatomic,copy) NSString * titleText;
@end
