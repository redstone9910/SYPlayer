//
//  SYPlayerLrcView.h
//  SYPlayer
//
//  Created by YinYanhui on 15-3-22.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYLrc;
@class SYSong;
@class SYLrcLine;

@protocol SYLrcDelegate <NSObject>
@optional
/** 拖动进度条 */
-(void)lrcProgressChanged:(SYLrc *)lrc;
/** 一句变色之前 */
-(BOOL)lrcLineShouldUpdate:(SYLrc *)lrc;
/** 一句变色之后 */
-(void)lrcLineDidUpdate:(SYLrc *)lrc;
@end

@interface SYLrc : UIView
/** 当前播放进度(秒) */
@property (nonatomic,assign) float timeProgressInSecond;
/** 背景图片Scroll */
@property (weak, nonatomic) UIScrollView *backgroundScroll;
@property (nonatomic,assign) BOOL clearMode;
/** 数据源 */
@property (nonatomic,strong) SYSong *song;
/** 当前行 */
@property (nonatomic,strong) SYLrcLine *playingLine;
/** 上一行 */
@property (nonatomic,strong) SYLrcLine *prevLine;

/** 创建新LRC View */
+(instancetype) lrc;
/** 跳转到下一句(单句模式需要手动调用) */
-(void)nextSentence;
/** 代理 */
@property (nonatomic,weak) id <SYLrcDelegate> delegate;
@end
