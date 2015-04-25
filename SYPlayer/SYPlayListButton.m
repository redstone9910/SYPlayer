//
//  SYPlayListButton.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-21.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYPlayListButton.h"
#import "NSString+Tools.h"

@interface SYPlayListButton()
- (IBAction)listBtnClick;

@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet UIImageView *titleArrow;

@end

@implementation SYPlayListButton

-(void)setOpened:(BOOL)Opened
{
    _Opened = Opened;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.titleArrow.transform = CGAffineTransformMakeRotation((self.isOpened ? 179.9 : 0) * M_PI / 180);
    }];
    
    if ([self.delegate respondsToSelector:@selector(playListButtonBtnClicked:)]) {
        [self.delegate playListButtonBtnClicked:self];
    }
}
/** 点击下拉列表 */
- (IBAction)listBtnClick{
    self.Opened = !self.isOpened;
}

+(instancetype) playListButtonWithString:(NSString *) titleString
{
    NSBundle * bundle = [NSBundle mainBundle];
    NSArray * objs = [bundle loadNibNamed:NSStringFromClass(self) owner:nil options:nil];
    SYPlayListButton * plbtn = [objs lastObject];
    plbtn.titleText = titleString;
    return plbtn;
}

+(instancetype) playListButton
{
    return [self playListButtonWithString:nil];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    float titleLength = [self.titleText sizeWithFont:self.titleBtn.titleLabel.font maxSize:CGSizeMake(1000, 1000)].width;
    float arrowCenterX = (self.bounds.size.width + titleLength + self.titleArrow.bounds.size.width) / 2;
    
    self.titleArrow.center = CGPointMake(arrowCenterX, self.titleArrow.center.y);
}
/** 设定标题 */
-(void)setTitleText:(NSString *)titleText
{
    _titleText = titleText;
    
    [self.titleBtn setTitle:self.titleText forState:normal];
}
-(void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
}
@end
