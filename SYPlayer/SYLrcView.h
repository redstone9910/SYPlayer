//
//  SYPlayerLrcView.h
//  SYPlayer
//
//  Created by YinYanhui on 15-3-22.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYLrcView;

typedef enum lrcPlayMode
{
    lrcPlayModeWhole = 0,
    lrcPlayModeSingleSentence = 1,
} lrcPlayMode;

@protocol SYLrcViewDelegate <NSObject>
/** 拖动进度条 */
-(void)lrcViewProgressChanged:(SYLrcView *)lrcView;
/** 单句模式暂停 */
-(void)lrcView:(SYLrcView *)lrcView sentenceInterval:(float)inteval sentence:(NSString *)sentence time:(float)time;
/** 单句模式播放完 */
//-(void)lrcView:(SYLrcView *)lrcView finishPlaying:
@end

@interface SYLrcView : UIView
/** LRC源文件(全路径) */
@property (nonatomic,copy) NSString * lrcFile;
/** 当前播放进度(秒) */
@property (nonatomic,assign) float timeProgressInSecond;
/** 单曲/单句模式 */
@property (nonatomic,assign) lrcPlayMode playMode;
/** 跳转到下一句(单句模式需要手动调用) */
-(NSString *)nextSentence:(float)time;
/** 背景图片Scroll */
@property (strong, nonatomic) UIScrollView *backgroundScroll;
/** 创建新LRC View */
+(instancetype) lrcView;
/** 代理 */
@property (nonatomic,weak) id <SYLrcViewDelegate> delegate;
@end
