//
//  SYPlayerLrcView.h
//  SYPlayer
//
//  Created by YinYanhui on 15-3-22.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYLrcView;

@protocol SYLrcViewDelegate <NSObject>

/** 拖动进度条 */
-(void)lrcViewProgressChanged:(SYLrcView *)lrcView;

@end

@interface SYLrcView : UIView
/** LRC源文件(全路径) */
@property (nonatomic,copy) NSString * lrcFile;
/** 当前播放进度(秒) */
@property (nonatomic,assign) float timeProgressInSecond;
/** 背景图片 */
@property (nonatomic,strong) UIImage * backgroundImage;

/** 创建新LRC View并设定LRC文件 */
+(instancetype) lrcViewWithFrame:(CGRect)frame withLrcFile:(NSString *)file;

/** 代理 */
@property (nonatomic,strong) id <SYLrcViewDelegate> delegate;
@end
