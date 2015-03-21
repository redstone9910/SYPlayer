//
//  SYPlayingViewController.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-21.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYPlayingViewController.h"
#import "SYPlayListButton.h"
#import "SYPlayerConsole.h"

@interface SYPlayingViewController ()<SYPlayListButtonDelegate>

@property (weak, nonatomic) IBOutlet UIButton *favoriteBtn;

- (IBAction)favoriteBtnClick;

- (IBAction)menuBtnClick;

@property (nonatomic,assign,getter=isFavoriteSong) BOOL favoriteSong;

@end

@implementation SYPlayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.hidden = NO;
    SYPlayListButton *titleBtn = [SYPlayListButton playListButtonWithString:@"第一册"];
    titleBtn.delegate = self;
    self.navigationItem.titleView = titleBtn;

    SYPlayerConsole *consoleView = [SYPlayerConsole playerConsole];
    float consolY = self.view.bounds.size.height - consoleView.bounds.size.height;
    CGRect frame = CGRectMake(0, consolY, consoleView.bounds.size.width, consoleView.bounds.size.height);
    consoleView.frame = frame;
    consoleView.timeTotalInSecond = 300;
    
    [self.view addSubview:consoleView];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - SYPlayListButtonDelegate

-(void)playListButtonBtnClicked:(SYPlayListButton *)playListBtn
{
//    NSLog(@"%@ Clicked!",playListBtn);
}

- (IBAction)favoriteBtnClick {
    self.favoriteSong = !self.isFavoriteSong;
    if (self.isFavoriteSong) {
        [self.favoriteBtn setImage:[UIImage imageNamed:@"star5_full"] forState:UIControlStateNormal];
    }
    else
    {
        [self.favoriteBtn setImage:[UIImage imageNamed:@"star5"] forState:UIControlStateNormal];
    }
}

- (IBAction)menuBtnClick {
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.navigationBar.hidden = YES;
}

@end
