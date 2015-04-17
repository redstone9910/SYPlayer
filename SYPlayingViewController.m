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
#import "SYAudioController.h"
#import "MIBServer.h"
#import "UIImageView+WebCache.h"
#import "Reachability.h"
#import "UIAlertView+Blocks.h"
#import "FSPlaylistItem.h"
#import <MediaPlayer/MediaPlayer.h>

#import "MBProgressHUD.h"
#import "FSAudioController.h"

#import "Gloable.h"

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
/** 更新songModelArrary内容到plist文件 */
-(BOOL)refreshSongModelArrary;
/** 流媒体播放器 */
@property (nonatomic,strong) SYAudioController * audioController;
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
@property (nonatomic,strong) NSIndexPath *selectedIndexpath;
/** 正在下载的行 */
@property (nonatomic,strong) NSIndexPath *downloadingIndexpath;
/** 下载提示窗口 */
@property (nonatomic,strong) UIAlertView * downloadAlert;
/** 下载 */
-(void)downloadToDir:(NSString *)dirPath OnModel:(SYSongModel *)model;
/** 下载（带WIFI检测） */
-(void)downloadWithWifiCheckToDir:(NSString *)dirPath OnModel:(SYSongModel *)model;

/** 播放model对应的歌曲 */
-(BOOL)playModel:(SYSongModel *)model;
@end

@implementation SYPlayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *path = [catchePath stringByAppendingPathComponent:[NSString stringWithFormat:@"song_list_%@.plist",self.playListModel.lessonTitle]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        path = [SYSongModel songModelArrayWithFileNameArray:self.playListModel.songList withPlistFileName:[NSString stringWithFormat:@"song_list_%@.plist",self.playListModel.lessonTitle] atPath:self.playListModel.lessonTitle];
    }
    self.plistPath = path;
    
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
    
    float tableX = self.playListTable.frame.origin.x;
    float tableY = self.playListTable.frame.origin.y;
    float tableH = self.playerConsole.frame.origin.y - tableY;
    float tableW = self.playListTable.frame.size.width;
    self.playListFrame = CGRectMake(tableX, tableY, tableW, tableH);
    self.playListTable.frame = self.playListFrame;
    self.playListTable.rowHeight = 30;
    [self.view bringSubviewToFront:self.playListTable];
    self.playListTable.delegate = self;
    self.playListTable.dataSource = self;
    
    self.audioController.delegate = self;
    
    [self.view bringSubviewToFront:self.menuBtn];
    [self.view bringSubviewToFront:self.favoriteBtn];
    
    __weak SYPlayingViewController *weakSelf = self;
    
    self.audioController.onStateChange = ^(FSAudioStreamState state) {
        switch (state) {
            case kFsAudioStreamRetrievingURL:
                NSLog(@"kFsAudioStreamRetrievingURL");
                break;
            case kFsAudioStreamStopped:
                NSLog(@"kFsAudioStreamStopped");
                weakSelf.playerConsole.playing = NO;
                break;
            case kFsAudioStreamBuffering:
//                NSLog(@"kFsAudioStreamBuffering");
                break;
            case kFsAudioStreamSeeking:
//                NSLog(@"kFsAudioStreamSeeking");
                break;
            case kFsAudioStreamPlaying:
                NSLog(@"kFsAudioStreamPlaying");
                weakSelf.playerConsole.playing = YES;
                break;
            case kFsAudioStreamFailed:
                NSLog(@"kFsAudioStreamFailed");
                break;
            case kFsAudioStreamPlaybackCompleted:
                NSLog(@"kFsAudioStreamPlaybackCompleted");
                if(weakSelf.selectedIndexpath.row < [weakSelf.playListTable numberOfRowsInSection:weakSelf.selectedIndexpath.section] - 1) {
                    [weakSelf playerConsoleNext:nil];
                }else{
                    weakSelf.playerConsole.playing = NO;
                    weakSelf.playerConsole.stopped = YES;
//                    weakSelf.playerConsole.timeTotalInSecond = 0;
                }
                break;
            case kFsAudioStreamRetryingStarted:
                NSLog(@"kFsAudioStreamRetryingStarted");
                break;
            case kFsAudioStreamRetryingSucceeded:
                NSLog(@"kFsAudioStreamRetryingSucceeded");
                break;
            case kFsAudioStreamRetryingFailed:
                NSLog(@"kFsAudioStreamRetryingFailed");
                break;
                
            default:
                break;
        }
    };
    
    self.audioController.onFailure = ^(FSAudioStreamError error, NSString *errorDescription) {
        NSString *errorCategory;
        
        switch (error) {
            case kFsAudioStreamErrorOpen:
                errorCategory = @"Cannot open the audio stream: ";
                break;
            case kFsAudioStreamErrorStreamParse:
                errorCategory = @"Cannot read the audio stream: ";
                break;
            case kFsAudioStreamErrorNetwork:
                errorCategory = @"Network failed: cannot play the audio stream: ";
                break;
            case kFsAudioStreamErrorUnsupportedFormat:
                errorCategory = @"Unsupported format: ";
                break;
            case kFsAudioStreamErrorStreamBouncing:
                errorCategory = @"Network failed: cannot get enough data to play: ";
                break;
            default:
                errorCategory = @"Unknown error occurred: ";
                break;
        }
        
        NSString *formattedError = [NSString stringWithFormat:@"%@ %@", errorCategory, errorDescription];
        NSLog(@"%@",formattedError);
    };
    
    self.audioController.onMetaDataAvailable = ^(NSDictionary *metaData) {
        NSMutableString *streamInfo = [[NSMutableString alloc] init];
        
//        [weakSelf determineStationNameWithMetaData:metaData];
        
        Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
        
        if (playingInfoCenter) {
            NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
            
            if (metaData[@"MPMediaItemPropertyTitle"]) {
                songInfo[MPMediaItemPropertyTitle] = metaData[@"MPMediaItemPropertyTitle"];
            } else if (metaData[@"StreamTitle"]) {
                songInfo[MPMediaItemPropertyTitle] = metaData[@"StreamTitle"];
            }
            
            if (metaData[@"MPMediaItemPropertyArtist"]) {
                songInfo[MPMediaItemPropertyArtist] = metaData[@"MPMediaItemPropertyArtist"];
            }
#warning 锁屏控制功能不好用
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        }
        
        if (metaData[@"MPMediaItemPropertyArtist"] &&
            metaData[@"MPMediaItemPropertyTitle"]) {
            [streamInfo appendString:metaData[@"MPMediaItemPropertyArtist"]];
            [streamInfo appendString:@" - "];
            [streamInfo appendString:metaData[@"MPMediaItemPropertyTitle"]];
        } else if (metaData[@"StreamTitle"]) {
            [streamInfo appendString:metaData[@"StreamTitle"]];
        }

        weakSelf.playerConsole.statusText = streamInfo;
        
    };

    if(!self.audioController.isPlaying){
        SYSongModel *model = self.songModelArrary[0];
        [self playModel:model];
    }
    
    if (!self.progressUpdateTimer) {
        self.progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                                        target:self
                                                                      selector:@selector(updatePlaybackProgress)
                                                                      userInfo:nil
                                                                       repeats:YES];
    }
}

-(FSStreamConfiguration *)configuration
{
    if (_configuration == nil) {
        _configuration = [[FSStreamConfiguration alloc] init];
        _configuration.usePrebufferSizeCalculationInSeconds = YES;
    }
    return _configuration;
}

/** 菜单按钮 */
- (IBAction)menuBtnClick {
#warning 增加"下载全部"菜单
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
/** 更新songModelArrary内容到plist文件 */
-(BOOL)refreshSongModelArrary
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (SYSongModel *model in self.songModelArrary) {
        NSDictionary *dict = [model dictFromSongModel];
        [array addObject:dict];
    }
    [array writeToFile:self.plistPath atomically:YES];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:self.plistPath];
}

#warning 拖动过快时播放会死机
/** 更新播放进度 */
- (void)updatePlaybackProgress
{
    self.seeking = YES;
    if (self.audioController.activeStream.continuous) {
//        self.playerConsole.timeProgressInSecond = 0;
//        self.playerConsole.timeTotalInSecond = 0;
    } else {
        FSStreamPosition cur = self.audioController.activeStream.currentTimePlayed;
        FSStreamPosition end = self.audioController.activeStream.duration;
        float timeTotle = end.minute * 60 + end.second;
        if (self.playerConsole.timeTotalInSecond != timeTotle) {
            self.playerConsole.timeTotalInSecond = timeTotle;
        }
        self.playerConsole.timeProgressInSecond = cur.playbackTimeInSeconds;
        self.lrcView.timeProgressInSecond = cur.playbackTimeInSeconds;
    }
}
/** 跳转到播放位置 */
-(void)seekToNewTime:(float)newTime
{
    FSStreamPosition pos = {0};
    pos.position = newTime / self.playerConsole.timeTotalInSecond;
    
    [self.audioController.activeStream seekToPosition:pos];
//    NSLog(@"seekToNewTime:%.1f",newTime);
}

/** 下载（带WIFI检测） */
-(void)downloadWithWifiCheckToDir:(NSString *)dirPath OnModel:(SYSongModel *)model
{
    Reachability *wifiChecker = [Reachability reachabilityForInternetConnection];
    if ([wifiChecker isReachableViaWiFi]) {
        [self downloadToDir:dirPath OnModel:model];
    }else{
        RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:@"取消" action:^{
        }];
        RIButtonItem *okButtonItem = [RIButtonItem itemWithLabel:@"我是土豪继续下载" action:^{
            [self downloadToDir:dirPath OnModel:model];
        }];
        
        UIAlertView *wifiAlert = [[UIAlertView alloc] initWithTitle:@"警告!木有WiFi!" message:@"继续下载可能会产生流量费用哦！" cancelButtonItem:cancelButtonItem otherButtonItems:okButtonItem, nil];
        [wifiAlert show];
    }
}
/** 下载 */
-(void)downloadToDir:(NSString *)dirPath OnModel:(SYSongModel *)model
{
    long index = [self.songModelArrary indexOfObject:model];
    self.downloadingIndexpath = [NSIndexPath indexPathForRow:index inSection:0];
    
    [model prepareDownloadToFile:dirPath onDownloading:^(float progress) {
        [self.playListTable reloadRowsAtIndexPaths:@[self.downloadingIndexpath] withRowAnimation:NO];
    } onComplete:^(BOOL complete) {
        [self.playListTable reloadRowsAtIndexPaths:@[self.downloadingIndexpath] withRowAnimation:NO];
        if (complete) {
            [self refreshSongModelArrary];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"下载失败" message:@"貌似网络不给力呀亲╭(╯3╰)╮" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

-(BOOL)playModel:(SYSongModel *)model
{
    if(model == nil) return NO;
    
    if([model findPath:self.playListModel.lessonTitle]){
        [self refreshSongModelArrary];
    }
    if (model.downloadProgress < 1)
    {
        long index = [self.songModelArrary indexOfObject:model];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.playListTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
    }
    
    if (model.downloadProgress >= 1) {
        NSString *mp3Path = model.mp3URL;
        if([mp3Path hasPrefix:@"/"]) mp3Path = [@"file://" stringByAppendingPathComponent:[mp3Path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURL *url = [NSURL URLWithString:mp3Path];
        
        self.audioController.url = url;
        [self.audioController play];
        self.playerConsole.playing = YES;
        
        NSString *lrcPath = [model.mp3URL stringByReplacingOccurrencesOfString:@"mp3" withString:@"lrc"];
        self.lrcView.lrcFile = lrcPath;
        
        NSArray *ary = [model.songName componentsSeparatedByString:@"－"];
        NSString *str = [ary firstObject];
        self.titleBtn.titleText = [NSString stringWithFormat:@"%@-%@",self.playListModel.lessonTitle,str];
        
        self.titleBtn.Opened = NO;
        
//        MPMediaItemArtwork *albumArt = [ [MPMediaItemArtwork alloc] initWithImage: [UIImage imageNamed:@"main_bg"]];
//        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
//        songInfo[MPMediaItemPropertyTitle] = model.songName;
//        songInfo[MPMediaItemPropertyArtist] = @"新概念英语";
//        songInfo[MPMediaItemPropertyAlbumTitle] = self.playListModel.lessonTitle;
//        [songInfo setObject: albumArt forKey:MPMediaItemPropertyArtwork ];
//        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        
        long index = [self.songModelArrary indexOfObject:model];
        self.selectedIndexpath = [NSIndexPath indexPathForRow:index inSection:0];
        return YES;
    }
    
    if (model.downloading == NO) {
        long index = [self.songModelArrary indexOfObject:model];
        self.downloadingIndexpath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.downloadAlert show];
    }
    
    if (self.selectedIndexpath != nil) {
        SYSongModel *lastModel = self.songModelArrary[self.selectedIndexpath.row];
        if(lastModel != model){
            [self playModel:lastModel];
        }
        self.titleBtn.Opened = YES;
    }else{
        //停止
        self.playerConsole.stopped = YES;
        [self.audioController stop];
        self.lrcView.lrcFile = nil;
        self.titleBtn.Opened = YES;
    }
    
    return NO;
}

#pragma - mark Property
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
/** 延迟加载audioController */
-(FSAudioController *)audioController
{
    if(_audioController == nil)
    {
        _audioController = [[SYAudioController alloc] init];
    }
    return _audioController;
}

#pragma mark - SYPlayerConsoleDelegate

/** 下一首 */
-(void)playerConsoleNext:(SYPlayerConsole *)console{
    NSIndexPath *newIndexPath = self.selectedIndexpath;
    if (newIndexPath.row < [self.playListTable numberOfRowsInSection:newIndexPath.section] - 1) {
        newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row + 1 inSection:newIndexPath.section];
        [self.playListTable selectRowAtIndexPath:newIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        SYSongModel *model = self.songModelArrary[newIndexPath.row];
        [self playModel:model];
        self.titleBtn.Opened = NO;
    }
}
/** 上一首 */
-(void)playerConsolePrev:(SYPlayerConsole *)console{
    NSIndexPath *newIndexPath = self.selectedIndexpath;
    if (newIndexPath.row > 0) {
        newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row - 1 inSection:newIndexPath.section];
        [self.playListTable selectRowAtIndexPath:newIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        SYSongModel *model = self.songModelArrary[newIndexPath.row];
        [self playModel:model];
        self.titleBtn.Opened = NO;
    }
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
    if (console.isPlaying) {
        [self.audioController pause];
    }
    else [self.audioController pause];
}
/** 退出键按下 */
-(void)playerConsolePowerOff:(SYPlayerConsole *)console{
    [self dismissViewControllerAnimated:YES completion:^{
//        self.audioController = nil;
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
    SYSongModel *model = self.songModelArrary[indexPath.row];
    if([model findPath:self.playListModel.lessonTitle]){
        [self refreshSongModelArrary];
    }

    cell.playListData = model;
    cell.delegate = self;
    
    return cell;
}

#pragma mark playListTableDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.downloadingIndexpath = indexPath;
    SYSongModel *model = self.songModelArrary[indexPath.row];
    [self playModel:model];
}

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        SYSongModel *model = self.songModelArrary[self.downloadingIndexpath.row];
        
        NSString *dirPath = [catchePath stringByAppendingPathComponent:self.playListModel.lessonTitle];
        [self downloadWithWifiCheckToDir:dirPath OnModel:model];
    }
}

#pragma mark SYSongCellDelegate
-(void)songCellDownloadBtnClick:(SYSongCell *)cell
{
    self.downloadingIndexpath = [self.playListTable indexPathForCell:cell];
    SYSongModel *model = self.songModelArrary[self.downloadingIndexpath.row];
    
    NSString *dirPath = [catchePath stringByAppendingPathComponent:self.playListModel.lessonTitle];
    if (model.downloading == NO) {
        [self downloadWithWifiCheckToDir:dirPath OnModel:model];
    }
}
/*
#pragma - mark Private

- (void)clearStatus
{
    [AJNotificationView hideCurrentNotificationViewAndClearQueue];
}

- (void)showStatus:(NSString *)status
{
    [self clearStatus];
    
    [AJNotificationView showNoticeInView:[[[UIApplication sharedApplication] delegate] window]
                                    type:AJNotificationTypeDefault
                                   title:status
                         linedBackground:AJLinedBackgroundTypeAnimated
                               hideAfter:0];
}

- (void)showErrorStatus:(NSString *)status
{
    [self clearStatus];
    
    [AJNotificationView showNoticeInView:[[[UIApplication sharedApplication] delegate] window]
                                    type:AJNotificationTypeRed
                                   title:status
                               hideAfter:10];
}
*/
@end
