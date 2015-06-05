//
//  SYRecordView.h
//  SYPlayer
//
//  Created by YinYanhui on 15-4-26.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^playCompletion)();
typedef void(^recordCompletion)(NSString *recordPath);

@interface SYRecordView : UIView
/** 创建新对象 */
+(instancetype)recordView;
/** 加载句子 */
-(BOOL)loadSentence:(NSString *)sentence songName:(NSString *)name duration:(float)duration;
/** 开始播放原音 */
-(void)startPlayCompletion:(playCompletion)block;
/** 开始录音 */
-(void)startRecordCompletion:(recordCompletion)block;
/** 停止 */
-(void)stop;

/** 播放进度 */
@property (nonatomic,assign) float timeProgress;
/** 中央图片宽度比例 */
@property (nonatomic,assign) float micScale;
/** 正在动画 */
@property (nonatomic,assign,getter=isAnimating) BOOL animating;
@end
