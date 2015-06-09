//
//  SYLrcLine.m
//  SYPlayer
//
//  Created by YinYanhui on 15/6/8.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYLrcLine.h"
#import "Gloable.h"

#define timeOffset -0.1

@implementation SYLrcTools

/** 时间标签转float */
+(float)timeWithString:(NSString *)string
{
    NSArray *array = [string componentsSeparatedByString:@":"];
    NSString *mStr = array[0];
    NSString *sStr = array[1];
    return [mStr floatValue] * 60 + [sStr floatValue];
}
@end

@interface SYLrcLine ()
@end

@implementation SYLrcLine

/** 创建lrcLine并赋值 */
+(instancetype)lrcLineWithLine:(NSString *)line{
    return [[self alloc] initWithLine:line];
}
/** 初始化lrcLine并赋值 */
-(instancetype)initWithLine:(NSString *)line{
    if (self = [super init]) {
        self.line = line;
        self.label.numberOfLines = 0;
        self.state = lineStateFuture;
        [self updateState];
    }
    return self;
}

/** 接收timeUpdate通知 */
-(void)timeUpdate:(NSNotification *)notification{
    
}
/** 格式示例:[00:26.50]Tim is an engineer. */
-(void)setLine:(NSString *)line{
    _line = line;
    if (_line.length) {
        
        NSArray *obj = [_line componentsSeparatedByString:@"]"];
        NSString *lineStr = obj[1];
        lineStr = [lineStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        lineStr = [lineStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        NSString *timeStr1 = obj[0];
        NSArray *timeObj2 = [timeStr1 componentsSeparatedByString:@"["];
        NSString *timeStr2 = timeObj2[1];
        float time = [SYLrcTools timeWithString:timeStr2] + timeOffset;
        
//        int minute = (int)time / 60;
//        float second = time - minute * 60;
//        minute %= 60;
//        NSString *timeStr = [NSString stringWithFormat:@"%02d:%02d.%02d",minute,(int)second,(int)((second - (int)second) * 100)];
        
        NSString *pStr1 = [timeStr2 substringWithRange:NSMakeRange(2, 1)];
        NSString *pStr2 = [timeStr2 substringWithRange:NSMakeRange(5, 1)];
        
        _text = lineStr;
        _startTime = time;
        if (!((timeStr2.length == 8) && ([pStr1 isEqualToString:@":"]) && ([pStr2 isEqualToString:@"."]))){
            _line = nil;
            _startTime = 0;
        }
        
        if (_label == nil) {
            _label = [[UILabel alloc] init];
        }
        _label.text = _text;
    }
}

/** update state */
-(void)updateState{
    switch (_state) {
        case lineStatePast:
        {
            self.label.font = [UIFont fontWithName:@"Helvetica-ObLique" size:15];
            self.label.textColor = [UIColor whiteColor];
            break;
        }
        case lineStateCurrent:
        {
            self.label.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
            self.label.textColor = lightGreenColor;
            break;
        }
        case lineStateFuture:
        {
            self.label.font = [UIFont fontWithName:@"Helvetica-ObLique" size:15];
            self.label.textColor = [UIColor whiteColor];
            break;
        }
        default:
            break;
    }
}
@end
