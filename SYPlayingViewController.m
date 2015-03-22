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
#import "MBProgressHUD.h"

@interface SYPlayingViewController ()<SYPlayListButtonDelegate,SYPlayerConsoleDelegate>

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
    consoleView.delegate = self;
    
    [self.view addSubview:consoleView];
}

- (IBAction)menuBtnClick {
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - SYPlayListButtonDelegate

/** 播放列表展开/关闭 */
-(void)playListButtonBtnClicked:(SYPlayListButton *)playListBtn
{
//    NSLog(@"%@ Clicked!",playListBtn);
}

/** 收藏按钮按下 */
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
#pragma mark - SYPlayerConsoleDelegate

/** 下一首 */
-(void)playerConsoleNext:(SYPlayerConsole *)console
{
    NSLog(@"下一首");
}
/** 上一首 */
-(void)playerConsolePrev:(SYPlayerConsole *)console{
    NSLog(@"上一首");
}
/** 拖动进度条 */
-(void)playerConsoleProgressChanged:(SYPlayerConsole *)console {
    
    NSLog(@"拖动进度条:%%%02.1f",((float)console.timeProgressInSecond / (float)console.timeTotalInSecond) * 100);
}
/** 播放/暂停状态改变 */
-(void)playerConsolePlayingStatusChanged:(SYPlayerConsole *)console{
    NSLog(@"播放/暂停状态:%@",console.isPlaying ? @"Playing":@"Pause");
}
/** 退出键按下 */
-(void)playerConsolePowerOff:(SYPlayerConsole *)console{
    NSLog(@"退出");
}
/** 播放模式改变 */
-(void)playerConsolePlayModeStateChanged:(SYPlayerConsole *)console withModeName:(NSString *)name{
    NSLog(@"模式:%d,%@",console.playMode ,name);
//    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
//    [hud setLabelText:name];
//    [hud setMode:MBProgressHUDModeText];
//    [hud show:YES];
}
@end
