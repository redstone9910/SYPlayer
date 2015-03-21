//
//  SYPlayerConsole.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-21.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYPlayerConsole.h"

@interface SYPlayerConsole ()
/** 总时间 */
@property (weak, nonatomic) IBOutlet UILabel *timeTotal;
/** 剩余时间 */
@property (weak, nonatomic) IBOutlet UILabel *timeLeft;
/** 播放进度 */
@property (weak, nonatomic) IBOutlet UISlider *playSlider;

/** 背景图片 */
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImg;
/** 播放模式按钮 */
@property (weak, nonatomic) IBOutlet UIButton *playMode;
/** 退出 */
@property (weak, nonatomic) IBOutlet UIButton *powerBtn;
/** 播放/暂停按钮 */
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
/** 上一首 */
@property (weak, nonatomic) IBOutlet UIButton *prevBtn;
/** 下一首 */
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;


/** 改变播放模式 */
- (IBAction)playModeClick;
@end

@implementation SYPlayerConsole
+(instancetype)playerConsole
{
    NSBundle * bundle = [NSBundle mainBundle];
    NSArray * objs = [bundle loadNibNamed:NSStringFromClass(self) owner:nil options:nil];
    SYPlayerConsole * console = [objs lastObject];
    
    return console;
}
- (IBAction)playModeClick {
}

-(void)awakeFromNib
{
    
}
@end
