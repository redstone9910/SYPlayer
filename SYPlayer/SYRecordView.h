//
//  SYRecordView.h
//  SYPlayer
//
//  Created by YinYanhui on 15-4-26.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^recordCompletion)();

@interface SYRecordView : UIView
/** 创建新对象 */
+(instancetype)recordView;
/** 加载句子 */
-(BOOL)loadSentence:(NSString *)sentence lessonTitle:(NSString *)title duration:(float)duration completion:(recordCompletion)block;
@end
