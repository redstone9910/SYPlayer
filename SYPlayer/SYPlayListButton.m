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
- (IBAction)listBtnClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet UIImageView *titleArrow;

@property (nonatomic,assign,getter=isOpend) BOOL Opened;

@end

@implementation SYPlayListButton

- (IBAction)listBtnClick:(id) sender {
    if (self.isOpend) {
        self.Opened = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.titleArrow.transform = CGAffineTransformMakeRotation(0 * M_1_PI / 180);
        }];
    }
    else
    {
        self.Opened = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.titleArrow.transform = CGAffineTransformMakeRotation(179.9 * M_PI / 180);
        }];
    }
    
    if ([self.delegate respondsToSelector:@selector(playListButtonBtnClicked:)]) {
        [self.delegate playListButtonBtnClicked:self];
    }
}

+(instancetype) playListButtonWithString:(NSString *) titleString
{
    NSBundle * bundle = [NSBundle mainBundle];
    NSArray * objs = [bundle loadNibNamed:NSStringFromClass(self) owner:nil options:nil];
    SYPlayListButton * plbtn = [objs lastObject];
    [plbtn.titleBtn setTitle:titleString forState:normal];
    plbtn.backgroundColor = [UIColor clearColor];
    return plbtn;
}

+(instancetype) playListButton
{
    return [self playListButtonWithString:nil];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    NSString *title = self.titleBtn.titleLabel.text;
    float titleLength = [title sizeWithFont:self.titleBtn.titleLabel.font maxSize:CGSizeMake(100, 100)].width;
    float arrowCenterX = (self.bounds.size.width + titleLength + self.titleArrow.bounds.size.width) / 2;
    
    self.titleArrow.center = CGPointMake(arrowCenterX, self.titleArrow.center.y);
}
@end
