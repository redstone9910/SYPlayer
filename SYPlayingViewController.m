//
//  SYPlayingViewController.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-21.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//
#warning 收藏页功能
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
#import "MobClick.h"
#import "GDTMobBannerView.h"

#import "MBProgressHUD.h"
#import "FSAudioController.h"

#import "Gloable.h"

typedef void (^SYDownloadCompletion)();

#define __AD_PASSED__

#ifdef __AD_PASSED__
/** 广点通ID */
#define GDT_APPID @"1104489407"
#define GDT_BANNERID @"8030502229410206"
#else
/** 测试ID */
//#define GDT_APPID @"100720253"
//#define GDT_BANNERID @"9079537207574943610"
#endif

@interface SYPlayingViewController ()<SYPlayListButtonDelegate,SYPlayerConsoleDelegate,SYLrcViewDelegate,UITableViewDelegate,UITableViewDataSource,FSAudioControllerDelegate,SYSongCellDelegate,GDTMobBannerViewDelegate>
/** 全部下载按钮 */
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
/** 收藏按钮 */
@property (weak, nonatomic) IBOutlet UIButton *favoriteBtn;
/** 全部下载按钮按下 */
- (IBAction)downloadBtnClick;
/** 后退按钮按下 */
- (IBAction)backBtnClick;
/** 是否已收藏 */
//@property (nonatomic,assign,getter=isFavoriteSong) BOOL favoriteSong;

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
#warning 增加在线播放功能
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
/** 下载 */
-(void)downloadToDir:(NSString *)dirPath onModel:(SYSongModel *)model withCompletionBlock:(SYDownloadCompletion)completionBlock;
/** 下载（带WIFI检测） */
-(void)downloadWithWifiCheckToDir:(NSString *)dirPath onModel:(SYSongModel *)model withCompletionBlock:(SYDownloadCompletion)completionBlock;
/** 正在下载队列中 */
@property (nonatomic,assign) BOOL downloading;

/** 播放model对应的歌曲 */
-(BOOL)playModel:(SYSongModel *)model;

/** 广点通 */
@property (nonatomic,strong) GDTMobBannerView * bannerView;
@end

@implementation SYPlayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMutableString *t_evnt = [NSMutableString stringWithFormat:@"Volume:%@",self.playListModel.lessonTitle];
    [MobClick event:@"Enter" label:t_evnt];
    
    NSString *path = [catchePath stringByAppendingPathComponent:[NSString stringWithFormat:@"song_list_%@.plist",self.playListModel.lessonTitle]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        path = [SYSongModel songModelArrayWithFileNameArray:self.playListModel.songList withPlistFileName:[NSString stringWithFormat:@"song_list_%@.plist",self.playListModel.lessonTitle] atPath:self.playListModel.lessonTitle];
    }
    self.plistPath = path;
    
    /** 广点通 */
    CGRect gdtframe = CGRectMake(0, self.view.bounds.size.height - 50, self.view.bounds.size.width, 50);
    self.bannerView = [[GDTMobBannerView alloc] initWithFrame:gdtframe appkey:GDT_APPID placementId:GDT_BANNERID];
    
    /** 标题栏 */
    self.titleBtn = [SYPlayListButton playListButtonWithString:self.playListModel.lessonTitle];
    self.titleBtn.delegate = self;
    self.titleBtn.frame = CGRectMake(0, 20, self.view.bounds.size.width, 44);
    [self.view addSubview:self.titleBtn];

    /** 控制台 */
    SYPlayerConsole *consoleView = [SYPlayerConsole playerConsole];
    float consolY = self.view.bounds.size.height - consoleView.bounds.size.height - self.bannerView.bounds.size.height;
    CGRect frame = CGRectMake(0, consolY, self.view.bounds.size.width, consoleView.bounds.size.height);
    consoleView.frame = frame;
    consoleView.delegate = self;
    self.playerConsole = consoleView;
    [self.view addSubview:self.playerConsole];
    
    /** 歌词 */
    CGRect rect = self.view.frame;
    rect.origin.y = self.titleBtn.frame.origin.y + self.titleBtn.frame.size.height;
    rect.size.height = self.playerConsole.frame.origin.y - rect.origin.y;
    SYLrcView *lrcview = [SYLrcView lrcViewWithFrame:rect withLrcFile:nil];
    lrcview.delegate = self;
    self.lrcView = lrcview;
    [self.view addSubview:self.lrcView];
    
    /** 歌曲列表 */
    float tableX = self.playListTable.frame.origin.x;
    float tableY = self.playListTable.frame.origin.y;
    float tableH = self.playerConsole.frame.origin.y - tableY;
    float tableW = self.view.bounds.size.width;
    self.playListFrame = CGRectMake(tableX, tableY, tableW, tableH);
    self.playListTable.frame = self.playListFrame;
    self.playListTable.rowHeight = 30;
    [self.view bringSubviewToFront:self.playListTable];
    self.playListTable.delegate = self;
    self.playListTable.dataSource = self;
    
    /** 按钮移到最前 */
    [self.view bringSubviewToFront:self.downloadBtn];
    [self.view bringSubviewToFront:self.favoriteBtn];
    
    /** 播放器 */
    self.audioController = [SYAudioController sharedAudioController];
    self.audioController.delegate = self;
    
    /** 设定audioPlayer若干代码块 */
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
//        SYSongModel *model = self.songModelArrary[0];
//        [self playModel:model];
        weakSelf.playerConsole.stopped = YES;
    }
    
    if (!self.progressUpdateTimer) {
        self.progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updatePlaybackProgress) userInfo:nil repeats:YES];
    }
    
    /** 广点通 */
    self.bannerView.delegate = self; // 设置Delegate
    self.bannerView.currentViewController = self; //设置当前的ViewController
    self.bannerView.interval = 30; //【可选】设置刷新频率;默认30秒
    self.bannerView.isGpsOn = NO; //【可选】开启GPS定位;默认关闭
    self.bannerView.showCloseBtn = NO; //【可选】展⽰示关闭按钮;默认显⽰示
    self.bannerView.isAnimationOn = YES; //【可选】开启banner轮播和展现时的动画效果;默认开启
    [self.view addSubview:self.bannerView]; //添加到当前的view中
    [self.bannerView loadAdAndShow]; //加载⼲⼴广告并展⽰示
//    [self reLayoutSubviewsWithAdHeight:0];//设定广告条高度为0并重新布局
}

-(void)dealloc
{
    /** 广点通 */
    self.bannerView.delegate = nil;
    self.bannerView.currentViewController = nil;
    self.bannerView = nil;
}

-(void)reLayoutSubviewsWithAdHeight:(float)height
{
    /** 广点通 */
    CGRect gdtframe = CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height);
    self.bannerView.frame = gdtframe;
    
    /** 标题栏 */
    self.titleBtn.frame = CGRectMake(0, 20, self.view.bounds.size.width, 44);
    
    /** 控制台 */
    float consolY = self.view.bounds.size.height - self.playerConsole.bounds.size.height - self.bannerView.bounds.size.height;
    CGRect frame = CGRectMake(0, consolY, self.view.bounds.size.width, self.playerConsole.bounds.size.height);
    self.playerConsole.frame = frame;
    
    /** 歌词 */
    CGRect rect = self.view.frame;
    rect.origin.y = self.titleBtn.frame.origin.y + self.titleBtn.frame.size.height;
    rect.size.height = self.playerConsole.frame.origin.y - rect.origin.y;
    self.lrcView.frame = rect;
    
    /** 歌曲列表 */
    float tableX = self.playListTable.frame.origin.x;
    float tableY = self.playListTable.frame.origin.y;
    float tableH = self.playerConsole.frame.origin.y - tableY;
    float tableW = self.view.bounds.size.width;
    self.playListFrame = CGRectMake(tableX, tableY, tableW, tableH);
    self.playListTable.frame = self.playListFrame;
}
/** 全部下载按钮按下 */
- (IBAction)downloadBtnClick {
    __weak SYPlayingViewController *weakSelf = self;
    RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:@"取消" action:^{
        weakSelf.downloading = NO;
    }];
    
    SYSongModel *downloadModel = nil;
    for (SYSongModel *model in self.songModelArrary) {
        if (model.downloading == NO) {
            downloadModel = model;
            break;
        }
    }
    if (downloadModel != nil) {
        NSString *dirPath = [catchePath stringByAppendingPathComponent:self.playListModel.lessonTitle];
        RIButtonItem *okButtonItem = [RIButtonItem itemWithLabel:@"下载" action:^{
            [weakSelf downloadWithWifiCheckToDir:dirPath onModel:downloadModel withCompletionBlock:^{
                weakSelf.downloading = YES;
                [weakSelf downloadBtnClick];
            }];
        }];
        
        if (!self.downloading) {
            UIAlertView *downloadAlert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"全部下载本册吗？" cancelButtonItem:cancelButtonItem otherButtonItems:okButtonItem, nil];
            [downloadAlert show];
        }else{
            [self downloadWithWifiCheckToDir:dirPath onModel:downloadModel withCompletionBlock:^{
                weakSelf.downloading = YES;
                [weakSelf downloadBtnClick];
            }];
        }
    }else{
        self.downloading = NO;
    }
}
/** 后退按钮按下 */
- (IBAction)backBtnClick {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
//    self.favoriteSong = !self.isFavoriteSong;
//    if (self.isFavoriteSong) {
//        [self.favoriteBtn setImage:[UIImage imageNamed:@"star5_full"] forState:UIControlStateNormal];
//    }
//    else
//    {
//        [self.favoriteBtn setImage:[UIImage imageNamed:@"star5"] forState:UIControlStateNormal];
//    }
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
-(void)downloadWithWifiCheckToDir:(NSString *)dirPath onModel:(SYSongModel *)model withCompletionBlock:(SYDownloadCompletion)completionBlock
{
    Reachability *wifiChecker = [Reachability reachabilityForInternetConnection];
    if ([wifiChecker isReachableViaWiFi]) {
        [self downloadToDir:dirPath onModel:model withCompletionBlock:completionBlock];
    }else{
        RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:@"取消" action:^{
        }];
        RIButtonItem *okButtonItem = [RIButtonItem itemWithLabel:@"我是土豪继续下载" action:^{
            [self downloadToDir:dirPath onModel:model withCompletionBlock:completionBlock];
        }];
        
        UIAlertView *wifiAlert = [[UIAlertView alloc] initWithTitle:@"警告!木有WiFi!" message:@"继续下载可能会产生流量费用哦！" cancelButtonItem:cancelButtonItem otherButtonItems:okButtonItem, nil];
        [wifiAlert show];
        [NSTimer scheduledTimerWithTimeInterval:5 target:wifiAlert selector:@selector(dismissAnimated:) userInfo:nil repeats:NO];
    }
}
/** 下载 */
-(void)downloadToDir:(NSString *)dirPath onModel:(SYSongModel *)model withCompletionBlock:(SYDownloadCompletion)completionBlock
{
    long index = [self.songModelArrary indexOfObject:model];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    [model prepareDownloadToFile:dirPath onDownloading:^(float progress) {
        SYSongCell *cell = (SYSongCell *)[self.playListTable cellForRowAtIndexPath:indexPath];
        cell.playListData = model;
    } onComplete:^(BOOL complete) {
        [self.playListTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
        if (complete) {
            completionBlock();
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"下载失败" message:@"貌似网络不给力呀亲╭(╯3╰)╮" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

-(BOOL)playModel:(SYSongModel *)model
{
    if(model == nil) return NO;
    
    if([model checkPathUpdate:self.playListModel.lessonTitle]){
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
        
        NSMutableString *t_evnt = [NSMutableString stringWithFormat:@"Song:%@",model.songName];
        [MobClick event:@"Playing" label:t_evnt];
        
        return YES;
    }
    
    if (model.downloading == NO) {
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"取消"];
        RIButtonItem *okItem = [RIButtonItem itemWithLabel:@"下载" action:^{
            NSString *dirPath = [catchePath stringByAppendingPathComponent:self.playListModel.lessonTitle];
            [self downloadWithWifiCheckToDir:dirPath onModel:model withCompletionBlock:^{
            }];
        }];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"本课未下载" message:@"是否下载？" cancelButtonItem:cancelItem otherButtonItems:okItem, nil];
        [alert show];
        [NSTimer scheduledTimerWithTimeInterval:5 target:alert selector:@selector(dismissAnimated:) userInfo:nil repeats:NO];
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

#pragma mark - Property
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

#pragma mark - playListTable DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.songModelArrary count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYSongCell *cell = [SYSongCell cellWithTableView:tableView];
    SYSongModel *model = self.songModelArrary[indexPath.row];
    if([model checkPathUpdate:self.playListModel.lessonTitle]){
        [self refreshSongModelArrary];
    }

    cell.playListData = model;
    cell.delegate = self;
    
    return cell;
}

#pragma mark - playListTableDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYSongModel *model = self.songModelArrary[indexPath.row];
    [self playModel:model];
}

#pragma mark - SYSongCellDelegate
-(void)songCellDownloadBtnClick:(SYSongCell *)cell
{
    NSIndexPath *indexPath = [self.playListTable indexPathForCell:cell];
    SYSongModel *model = self.songModelArrary[indexPath.row];
    
    NSString *dirPath = [catchePath stringByAppendingPathComponent:self.playListModel.lessonTitle];
    if (model.downloading == NO) {
        [self downloadWithWifiCheckToDir:dirPath onModel:model withCompletionBlock:^{
        }];
    }
}

#pragma mark - GDTDelegate
// 请求⼲⼴广告条数据成功后调⽤用
- (void)bannerViewDidReceived{
}
// 请求⼲⼴广告条数据失败后调⽤用
- (void)bannerViewFailToReceived:(int)errCode{
    [self reLayoutSubviewsWithAdHeight:0];
}
// 应⽤用进⼊入后台时调⽤用
- (void)bannerViewWillLeaveApplication{
    
}
// 广告条曝光回调
- (void)bannerViewWillExposure{
    [self reLayoutSubviewsWithAdHeight:50];
}
// 广告条点击回调
- (void)bannerViewClicked{
    
}
// banner条被⽤用户关闭时调⽤用
- (void)bannerViewWillClose{
    [self reLayoutSubviewsWithAdHeight:0];
}

@end
