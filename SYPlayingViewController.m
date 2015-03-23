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
#import "SYLrcView.h"
#import "SYPlayListCell.h"
#import "SYPlayListModel.h"

#import "MBProgressHUD.h"
#import "FSAudioController.h"

@interface SYPlayingViewController ()<SYPlayListButtonDelegate,SYPlayerConsoleDelegate,SYLrcViewDelegate,UITableViewDelegate,UITableViewDataSource,FSAudioControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *favoriteBtn;
/** 菜单按钮按下 */
- (IBAction)menuBtnClick;
/** 收藏按钮按下 */
- (IBAction)favoriteBtnClick;
/** 是否已收藏 */
@property (nonatomic,assign,getter=isFavoriteSong) BOOL favoriteSong;

/** 播放下拉列表 */
@property (weak, nonatomic) IBOutlet UITableView *playListTable;
/** 控制台 */
@property (nonatomic,strong) SYPlayerConsole * playerConsole;
/** 歌词显示 */
@property (nonatomic,strong) SYLrcView *lrcView;

/** 用于保存playListTable原始Frame */
@property (nonatomic,assign) CGRect playListFrame;
/** 播放列表数据数组 */
@property (nonatomic,strong) NSArray * playListModelArrary;

@property (nonatomic,strong) FSAudioController * playerController;
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
    consoleView.timeTotalInSecond = 30;
    consoleView.delegate = self;
    self.playerConsole = consoleView;
    [self.view addSubview:self.playerConsole];
    
    CGRect rect = self.view.frame;
    rect.origin.y = self.navigationController.navigationBar.frame.size.height;//self.navigationController.navigationBar.frame.origin.y + 
    rect.size.height = self.playerConsole.frame.origin.y - rect.origin.y;
//    NSLog(@"%f,%f",rect.origin.y,self.navigationController.navigationBar.frame.origin.y);
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *file = [bundle pathForResource:@"001&002－Excuse Me.lrc" ofType:nil];
    SYLrcView *lrcview = [SYLrcView lrcViewWithFrame:rect withLrcFile:file];
    lrcview.delegate = self;
    self.lrcView = lrcview;
    [self.view addSubview:self.lrcView];
    
    self.playListFrame = self.playListTable.frame;
//    self.playListTable.backgroundColor = [UIColor redColor];
    [self.view bringSubviewToFront:self.playListTable];
    self.playListTable.delegate = self;
    self.playListTable.dataSource = self;
    
    self.playerController.delegate = self;
}
/** 菜单按钮 */
- (IBAction)menuBtnClick {
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.navigationBar.hidden = YES;
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
/** 延迟加载播放列表数据 */
-(NSArray *)playListModelArrary
{
    if (_playListModelArrary == nil) {
        NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PlayList" ofType:@"plist"]];
        NSMutableArray *retArray = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            SYPlayListModel *model = [SYPlayListModel playListModelWithDict:dict];
            [retArray addObject:model];
        }
        
        _playListModelArrary = retArray;
    }
    
    return _playListModelArrary;
}
/** 延迟加载playerController */
-(FSAudioController *)playerController
{
    if(_playerController == nil)
    {
        _playerController = [[FSAudioController alloc] init];
    }
    return _playerController;
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
    
//    NSLog(@"拖动进度条:%%%02.1f",((float)console.timeProgressInSecond / (float)console.timeTotalInSecond) * 100);
    self.lrcView.timeProgressInSecond = console.timeProgressInSecond;
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
#pragma - SYLrcViewDelegate
/** 拖动LRC视图改变播放进度 */
-(void)lrcViewProgressChanged:(SYLrcView *)lrcView
{
//    NSLog(@"%d",lrcView.timeProgressInSecond);
    self.playerConsole.timeProgressInSecond = lrcView.timeProgressInSecond;
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
    CGRect frame = self.playListFrame;
    if(!playListBtn.isOpened){
        frame.size.height = 0;
    }
    
    [self.view bringSubviewToFront:self.playListTable];
    [UIView animateWithDuration:0.3 animations:^{
        self.playListTable.frame = frame;
    }];
}

#pragma playListTable DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.playListModelArrary count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYPlayListCell *cell = [SYPlayListCell cellWithTableView:tableView];
    cell.playListData = self.playListModelArrary[indexPath.row];
    
    return cell;
}

#pragma playListTableDelegate
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexPath.row:%d",indexPath.row);
    SYPlayListModel *model = self.playListModelArrary[indexPath.row];
    
    NSString *urlStr = [[NSBundle mainBundle]pathForResource:model.mp3URL ofType:@"mp3"];
    urlStr = [@"file://" stringByAppendingString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    self.playerController.url = url;
    [self.playerController play];
}
#pragma FSAudioControllerDelegate

@end
