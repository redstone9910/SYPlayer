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

typedef enum lrcPlayMode
{
    lrcPlayModeWhole = 0,
    lrcPlayModeSingleSentence = 1,
} lrcPlayMode;

@protocol SYLrcViewDelegate <NSObject>
/** 拖动进度条 */
-(void)lrcProgressChanged:(SYLrc *)lrc;
/** 一句变色之前 */
-(BOOL)lrcLineShouldUpdate:(SYLrc *)lrc;
/** 一句变色之后 */
-(void)lrcLineDidUpdate:(SYLrc *)lrc;
/** 单句模式暂停 */
-(void)lrc:(SYLrc *)lrc sentenceInterval:(float)inteval sentence:(NSString *)sentence time:(float)time;
@end

@interface SYLrc : UIView
/** 当前播放进度(秒) */
@property (nonatomic,assign) float timeProgressInSecond;
/** 单曲/单句模式 */
@property (nonatomic,assign) lrcPlayMode playMode;
/** 背景图片Scroll */
@property (weak, nonatomic) UIScrollView *backgroundScroll;
@property (nonatomic,assign) BOOL clearMode;
/** 数据源 */
@property (nonatomic,strong) SYSong *song;

/** 创建新LRC View */
+(instancetype) lrc;
/** 跳转到下一句(单句模式需要手动调用) */
-(void)nextSentence;
/** 代理 */
@property (nonatomic,weak) id <SYLrcViewDelegate> delegate;
@end
