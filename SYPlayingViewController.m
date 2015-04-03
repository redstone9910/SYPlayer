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
#import "SYSongCell.h"
#import "SYSongModel.h"

#import "MBProgressHUD.h"
#import "FSAudioController.h"

@interface SYPlayingViewController ()<SYPlayListButtonDelegate,SYPlayerConsoleDelegate,SYLrcViewDelegate,UITableViewDelegate,UITableViewDataSource,FSAudioControllerDelegate,UIAlertViewDelegate,SYSongCellDelegate>
/** 菜单按钮 */
@property (weak, nonatomic) IBOutlet UIButton *menuBtn;
/** 收藏按钮 */
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
@property (nonatomic,strong) NSArray * songModelArrary;
/** 流媒体播放器 */
@property (nonatomic,strong) FSAudioController * playerController;
/** 更新播放进度定时器 */
@property (nonatomic,strong) NSTimer *progressUpdateTimer;

/** 更新播放进度 */
- (void)updatePlaybackProgress;
/** 跳转到播放位置 */
-(void)seekToNewTime:(float)newTime;
/** 正在更新播放进度 */
@property (nonatomic,assign,getter=isSeeking) BOOL seeking;

/** 标题按钮 */
@property (nonatomic,strong) SYPlayListButton *titleBtn;
/** 存储播放列表数据的plist文件路径 */
@property (nonatomic,copy) NSString * plistPath;
/** 当前被选中的行号 */
@property (nonatomic,assign) NSInteger selectedRowNum;
/** 下载提示窗口 */
@property (nonatomic,strong) UIAlertView * downloadAlert;

@end

@implementation SYPlayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *path = [SYSongModel songModelArrayWithFileNameArray:self.playListModel.songList withPlistFileName:@"song_list.plist" atPath:self.playListModel.lessonTitle];
    if (path != nil) {
        self.plistPath = path;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"本课未下载" message:@"是否下载？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"下载", nil];
    self.downloadAlert = alert;
    
    self.titleBtn = [SYPlayListButton playListButtonWithString:self.playListModel.lessonTitle];
    self.titleBtn.delegate = self;
    self.titleBtn.frame = CGRectMake(0, 20, self.view.frame.size.width, 44);
    [self.view addSubview:self.titleBtn];

    SYPlayerConsole *consoleView = [SYPlayerConsole playerConsole];
    float consolY = self.view.bounds.size.height - consoleView.bounds.size.height;
    CGRect frame = CGRectMake(0, consolY, consoleView.bounds.size.width, consoleView.bounds.size.height);
    consoleView.frame = frame;
    consoleView.timeTotalInSecond = 30;
    consoleView.delegate = self;
    self.playerConsole = consoleView;
    [self.view addSubview:self.playerConsole];
    
    CGRect rect = self.view.frame;
    rect.origin.y = self.titleBtn.frame.origin.y + self.titleBtn.frame.size.height;
    rect.size.height = self.playerConsole.frame.origin.y - rect.origin.y;
    SYLrcView *lrcview = [SYLrcView lrcViewWithFrame:rect withLrcFile:nil];
    lrcview.delegate = self;
    self.lrcView = lrcview;
    [self.view addSubview:self.lrcView];
    
    self.playListFrame = self.playListTable.frame;
    self.playListTable.rowHeight = 30;
    [self.view bringSubviewToFront:self.playListTable];
    self.playListTable.delegate = self;
    self.playListTable.dataSource = self;
    
    self.playerController.delegate = self;
    
    [self.view bringSubviewToFront:self.menuBtn];
    [self.view bringSubviewToFront:self.favoriteBtn];
    if (!self.progressUpdateTimer) {
        self.progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                        target:self
                                                                      selector:@selector(updatePlaybackProgress)
                                                                      userInfo:nil
                                                                       repeats:YES];
    }
}
/** 菜单按钮 */
- (IBAction)menuBtnClick {
    self.titleBtn.Opened = !self.titleBtn.isOpened;
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
-(NSArray *)songModelArrary
{
    if (_songModelArrary == nil) {
//        NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PlayList" ofType:@"plist"]];
        NSArray *array = [NSArray arrayWithContentsOfFile:self.plistPath];
        NSMutableArray *retArray = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            SYSongModel *model = [SYSongModel songModelWithDict:dict];
            [retArray addObject:model];
        }
        
        _songModelArrary = retArray;
    }
    
    return _songModelArrary;
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
/** 更新播放进度 */
- (void)updatePlaybackProgress
{
    self.seeking = YES;
    if (self.playerController.activeStream.continuous) {
//        self.playerConsole.timeProgressInSecond = 0;
//        self.playerConsole.timeTotalInSecond = 0;
    } else {
        FSStreamPosition cur = self.playerController.activeStream.currentTimePlayed;
        FSStreamPosition end = self.playerController.activeStream.duration;
        
        float timeTotle = end.minute * 60 + end.second;
        if (self.playerConsole.timeTotalInSecond != timeTotle) {
            self.playerConsole.timeTotalInSecond = timeTotle;
        }
        self.playerConsole.timeProgressInSecond = cur.minute * 60 + cur.second;
    }
}
/** 跳转到播放位置 */
-(void)seekToNewTime:(float)newTime
{
    FSStreamPosition pos = {0};
    pos.position = newTime / self.playerConsole.timeTotalInSecond;
    
    [self.playerController.activeStream seekToPosition:pos];
//    NSLog(@"seekToNewTime:%.1f",newTime);
}
#pragma mark - SYPlayerConsoleDelegate
/** 下一首 */
-(void)playerConsoleNext:(SYPlayerConsole *)console{
}
/** 上一首 */
-(void)playerConsolePrev:(SYPlayerConsole *)console{
}
/** 拖动进度条 */
-(void)playerConsoleProgressChanged:(SYPlayerConsole *)console {
    self.lrcView.timeProgressInSecond = console.timeProgressInSecond;
    if (self.isSeeking) {
        self.seeking = NO;
    }
    else [self seekToNewTime:console.timeProgressInSecond];
}
/** 播放/暂停状态改变 */
-(void)playerConsolePlayingStatusChanged:(SYPlayerConsole *)console{
//    NSLog(@"isPlaying = %d",console.isPlaying);
    if (console.isPlaying) {
        [self.playerController pause];
    }
    else [self.playerController pause];
}
/** 退出键按下 */
-(void)playerConsolePowerOff:(SYPlayerConsole *)console{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
/** 播放模式改变 */
-(void)playerConsolePlayModeStateChanged:(SYPlayerConsole *)console withModeName:(NSString *)name{
//    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
//    [hud setLabelText:name];
//    [hud setMode:MBProgressHUDModeText];
//    [hud show:YES];
}
#pragma mark - SYLrcViewDelegate
/** 拖动LRC视图改变播放进度 */
-(void)lrcViewProgressChanged:(SYLrcView *)lrcView
{
    self.playerConsole.timeProgressInSecond = lrcView.timeProgressInSecond;
    
    if (self.isSeeking) {
        self.seeking = NO;
    }
    else [self seekToNewTime:lrcView.timeProgressInSecond];
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

#pragma mark playListTable DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.songModelArrary count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYSongCell *cell = [SYSongCell cellWithTableView:tableView];
    cell.playListData = self.songModelArrary[indexPath.row];
    cell.delegate = self;
    
    return cell;
}

#pragma mark playListTableDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRowNum = indexPath.row;
    
    SYSongModel *model = self.songModelArrary[self.selectedRowNum];
    if (model.downloadProgress >= 1) {
        NSString *mp3Path = model.mp3URL;
        mp3Path = [@"file://" stringByAppendingString:[mp3Path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURL *url = [NSURL URLWithString:mp3Path];
        
        self.playerController.url = url;
        [self.playerController play];
        self.playerConsole.playing = YES;
        
        NSString *lrcPath = [model.mp3URL stringByReplacingOccurrencesOfString:@"mp3" withString:@"lrc"];
        self.lrcView.lrcFile = lrcPath;
        
        NSArray *ary = [model.songName componentsSeparatedByString:@"－"];
        NSString *str = [ary firstObject];
        self.titleBtn.titleText = [NSString stringWithFormat:@"%@-%@",self.playListModel.lessonTitle,str];
        
        self.titleBtn.Opened = NO;
    }else{
        if (model.downloading == NO) {
            [self.downloadAlert show];
        }
        else
        {
#warning 下载暂停
            NSLog(@"暂停");
        }
    }
}
#pragma mark FSAudioControllerDelegate

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        SYSongModel *model = self.songModelArrary[self.selectedRowNum];
        model.downloading = YES;
        [self.playListTable reloadData];
#warning 此处需添加更新文件下载进度的代码，以及在载入文件列表时判断下载进度
    }
}

#pragma mark SYSongCellDelegate
-(void)songCellDownloadBtnClick:(SYSongCell *)cell
{
    self.selectedRowNum = [self.playListTable indexPathForCell:cell].row;
    SYSongModel *model = self.songModelArrary[self.selectedRowNum];
    if (model.downloading == NO) {
        [self.downloadAlert show];
    }
    else
    {
#warning 下载暂停
        NSLog(@"暂停");
    }
}
@end
