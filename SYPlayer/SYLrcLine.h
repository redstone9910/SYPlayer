//
//  SYLrcLine.h
//  SYPlayer
//
//  Created by YinYanhui on 15/6/8.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    lineStatePast,
    lineStateCurrent,
    lineStateFuture,
} lineState;

@interface SYLrcTools : NSObject
/** 时间标签转float */
+(float)timeWithString:(NSString *)string;
@end

@interface SYLrcLine : NSObject
/** 创建lrcLine并赋值 */
+(instancetype)lrcLineWithLine:(NSString *)line;
/** 初始化lrcLine并赋值 */
-(instancetype)initWithLine:(NSString *)line;
/** update state */
-(void)updateState;

/** 格式示例:[00:26.50]Tim is an engineer. */
@property (nonatomic,copy) NSString *line;
/** 格式示例:Tim is an engineer. */
@property (nonatomic,copy,readonly) NSString *text;
/** 格式示例:26.5 */
@property (nonatomic,assign,readonly) float startTime;
/** 下一句开始时间 */
@property (nonatomic,assign) float endTime;
/** 当前状态 */
@property (nonatomic,assign) lineState state;
/** 内容不能更改,格式示例:Tim is an engineer. */
@property (nonatomic,strong,readonly) UILabel *label;
@end
