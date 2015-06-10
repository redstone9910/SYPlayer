//
//  SYLrcView.h
//  SYPlayer
//
//  Created by YinYanhui on 15/6/8.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYLrcView;
@class SYLrcLine;

@protocol SYLrcViewDelegate <NSObject>
@optional
-(BOOL)lrcViewLineShouldUpdate:(SYLrcView *)lrcView;
-(void)lrcViewLineDidUpdate:(SYLrcView *)lrcView;
-(void)lrcViewLineDidLayoutSubviews:(SYLrcView *)lrcView;
@end

@interface SYLrcView : UIView
+(instancetype)lrcView;
/** 跳转到下一句(单句模式需要手动调用) */
-(void)nextSentence;

/** 当前offset */
@property (nonatomic,assign) float offset;
/** 宽度 */
@property (nonatomic,assign) CGRect customFrame;
/** 当前时间 */
@property (nonatomic,assign) float currentTime;
/** LRC源文件(全路径) */
@property (nonatomic,copy) NSString *lrcFile;
/** 上一行 */
@property (nonatomic,strong) SYLrcLine *prevLine;
/** 正在播放行 */
@property (nonatomic,strong) SYLrcLine *playingLine;
/** 代理 */
@property (nonatomic,weak) id<SYLrcViewDelegate> delegate;
@end
