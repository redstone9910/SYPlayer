//
//  SYPlayingViewController.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-21.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//
#warning 收藏页功能
#warning 重设字体，字号，颜色，重设皮肤颜色功能
#import "SYPlayingViewController.h"
#import "SYTitleButton.h"
#import "SYPlayerConsole.h"
#import "SYLrcView.h"
#import "SYSongCell.h"
#import "SYSong.h"
#import "SYAudioController.h"
#import "MIBServer.h"
#import "UIImageView+WebCache.h"
#import "Reachability.h"
#import "UIAlertView+Blocks.h"
#import "FSPlaylistItem.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MobClick.h"
#import "GDTMobBannerView.h"
#import "SYRecordView.h"
#include "SYBackGroundScroll.h"
#import "SYPlaylist.h"
#import "SYPlaylists.h"

#import "MBProgressHUD.h"
#import "FSAudioController.h"

#import "Gloable.h"

typedef void (^SYDownloadCompletion)();

#define updateInterval 0.1

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

@interface SYPlayingViewController ()<SYTitleButtonDelegate,SYPlayerConsoleDelegate,SYLrcViewDelegate,UITableViewDelegate,UITableViewDataSource,FSAudioControllerDelegate,SYSongCellDelegate,GDTMobBannerViewDelegate>
/** 收藏按钮 */
@property (strong, nonatomic) IBOutlet UIButton *favoriteBtn;
/** 后退按钮 */
@property (strong, nonatomic) UIButton *backBtn;
/** 全部下载按钮按下 */
- (IBAction)favoriteBtnClick;
/** 后退按钮按下 */
- (IBAction)backBtnClick;

/** 背景图片Scroll */
@property (strong, nonatomic) SYBackGroundScroll *backgroundScroll;
/** 标题按钮 */
@property (nonatomic,strong) SYTitleButton *titleListBtn;
/** 控制台 */
@property (nonatomic,strong) SYPlayerConsole * playerConsole;
/** 歌词显示 */
@property (nonatomic,strong) SYLrcView *lrcView;
@property (strong, nonatomic) UITableView *playListTable;
/** 广点通 */
@property (nonatomic,strong) GDTMobBannerView * bannerView;
/** 录音面板 */
@property (nonatomic,strong) SYRecordView * recordView;
@property (nonatomic,strong) NSLayoutConstraint * recordWConstraint;

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

/** 存储播放列表数据的plist文件路径 */
//@property (nonatomic,copy) NSString * plistPath;
/** 当前被选中的行号 */
@property (nonatomic,strong) NSIndexPath *selectedIndexpath;
/** 下载 */
-(void)downloadToDir:(NSString *)dirPath onModel:(SYSong *)model withCompletionBlock:(SYDownloadCompletion)completionBlock;
/** 下载（带WIFI检测） */
-(void)downloadWithWifiCheckToDir:(NSString *)dirPath onModel:(SYSong *)model withCompletionBlock:(SYDownloadCompletion)completionBlock;
/** 正在下载队列中 */
@property (nonatomic,assign) BOOL downloading;

/** 播放model对应的歌曲 */
-(BOOL)playModel:(SYSong *)model;
@end

@implementation SYPlayingViewController
-(void)loadView{
    [super loadView];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    __weak typeof(self) weakSelf = self;
    
    SYPlaylist *playlist = self.playLists.playLists[self.playLists.playingIndex];
    self.playList = playlist;
    
    NSMutableString *t_evnt = [NSMutableString stringWithFormat:@"Volume:%@",self.playList.lessonTitle];
    [MobClick event:@"Enter" label:t_evnt];

    [self.view addSubview:self.backgroundScroll];
    {
        NSLayoutConstraint *cnsT = [NSLayoutConstraint constraintWithItem:self.backgroundScroll attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *cnsB = [NSLayoutConstraint constraintWithItem:self.backgroundScroll attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint *cnsL = [NSLayoutConstraint constraintWithItem:self.backgroundScroll attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint *cnsR = [NSLayoutConstraint constraintWithItem:self.backgroundScroll attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        [self.view addConstraints:@[cnsT,cnsB,cnsL,cnsR]];
    }
    
    /** 标题栏 */
    self.titleListBtn = [SYTitleButton playListButton];
    self.titleListBtn.titleText = self.playList.lessonTitle;
    [self.view addSubview:self.titleListBtn];
    self.titleListBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *cnsT1 = [NSLayoutConstraint constraintWithItem:self.titleListBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:20];
    NSLayoutConstraint *cnsL1 = [NSLayoutConstraint constraintWithItem:self.titleListBtn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *cnsR1 = [NSLayoutConstraint constraintWithItem:self.titleListBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    [self.view addConstraints:@[cnsT1,cnsL1,cnsR1]];
    
    NSLayoutConstraint *cnsH1 = [NSLayoutConstraint constraintWithItem:self.titleListBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44];
    [self.titleListBtn addConstraints:@[cnsH1]];
    
    self.titleListBtn.delegate = self;
    self.titleListBtn.Opened = NO;
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        self.titleListBtn.Opened = YES;
    });
    
    /** 后退按钮 */
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.titleListBtn addSubview:self.backBtn];
    {
        self.backBtn.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *cnsB5 = [NSLayoutConstraint constraintWithItem:self.backBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.titleListBtn attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint *cnsL5 = [NSLayoutConstraint constraintWithItem:self.backBtn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.titleListBtn attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint *cnsT5 = [NSLayoutConstraint constraintWithItem:self.backBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleListBtn attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [self.titleListBtn addConstraints:@[cnsB5,cnsL5,cnsT5]];
        NSLayoutConstraint *cnsW5 = [NSLayoutConstraint constraintWithItem:self.backBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44];
        [self.backBtn addConstraints:@[cnsW5]];
    }
    
    /** 全部下载按钮 */
    self.favoriteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.favoriteBtn setImage:[UIImage imageNamed:@"actionIconLike_b"] forState:UIControlStateNormal];
    [self.favoriteBtn setImage:[UIImage imageNamed:@"actionIconLikeSelected_b"] forState:UIControlStateSelected];
    [self.favoriteBtn addTarget:self action:@selector(favoriteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.titleListBtn addSubview:self.favoriteBtn];
    {
        self.favoriteBtn.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *cnsB5 = [NSLayoutConstraint constraintWithItem:self.favoriteBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.titleListBtn attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint *cnsR5 = [NSLayoutConstraint constraintWithItem:self.favoriteBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.titleListBtn attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        NSLayoutConstraint *cnsT5 = [NSLayoutConstraint constraintWithItem:self.favoriteBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleListBtn attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [self.titleListBtn addConstraints:@[cnsB5,cnsR5,cnsT5]];
        NSLayoutConstraint *cnsW5 = [NSLayoutConstraint constraintWithItem:self.favoriteBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44];
        [self.favoriteBtn addConstraints:@[cnsW5]];
    }
    
    /** 广点通 */
    CGRect gdtframe = CGRectMake(0, self.view.bounds.size.height - 50, self.view.bounds.size.width, 50);
    self.bannerView = [[GDTMobBannerView alloc] initWithFrame:gdtframe appkey:GDT_APPID placementId:GDT_BANNERID];
    self.bannerView.delegate = self; // 设置Delegate
    self.bannerView.currentViewController = self; //设置当前的ViewController
    self.bannerView.interval = 30; //【可选】设置刷新频率;默认30秒
    self.bannerView.isGpsOn = NO; //【可选】开启GPS定位;默认关闭
    self.bannerView.showCloseBtn = NO; //【可选】展⽰示关闭按钮;默认显⽰示
    self.bannerView.isAnimationOn = YES; //【可选】开启banner轮播和展现时的动画效果;默认开启
    [self.bannerView loadAdAndShow]; //加载⼲⼴广告并展⽰示
    
    [self.view addSubview:self.bannerView];
    self.bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *cnsB5 = [NSLayoutConstraint constraintWithItem:self.bannerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *cnsL5 = [NSLayoutConstraint constraintWithItem:self.bannerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *cnsR5 = [NSLayoutConstraint constraintWithItem:self.bannerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    [self.view addConstraints:@[cnsB5,cnsL5,cnsR5]];
    NSLayoutConstraint *cnsH5 = [NSLayoutConstraint constraintWithItem:self.bannerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:50];
    [self.bannerView addConstraints:@[cnsH5]];
//    [self reLayoutSubviewsWithAdHeight:50];//设定广告条高度为0并重新布局
    
    /** 控制台 */
    self.playerConsole = [SYPlayerConsole playerConsole];
    self.playerConsole.delegate = self;
    [self.view addSubview:self.playerConsole];
    self.playerConsole.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *cnsB2 = [NSLayoutConstraint constraintWithItem:self.playerConsole attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bannerView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *cnsL2 = [NSLayoutConstraint constraintWithItem:self.playerConsole attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *cnsR2 = [NSLayoutConstraint constraintWithItem:self.playerConsole attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    [self.view addConstraints:@[cnsB2,cnsL2,cnsR2]];
    
    NSLayoutConstraint *cnsH2 = [NSLayoutConstraint constraintWithItem:self.playerConsole attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
    [self.playerConsole addConstraints:@[cnsH2]];
    
    /** 歌词 */
    self.lrcView = [SYLrcView lrcView];
    self.lrcView.lrcFile = nil;
    self.lrcView.delegate = self;
    self.lrcView.backgroundScroll = self.backgroundScroll;
    
    [self.view addSubview:self.lrcView];
    self.lrcView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *cnsT3 = [NSLayoutConstraint constraintWithItem:self.lrcView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleListBtn attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *cnsB3 = [NSLayoutConstraint constraintWithItem:self.lrcView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.playerConsole attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *cnsL3 = [NSLayoutConstraint constraintWithItem:self.lrcView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *cnsR3 = [NSLayoutConstraint constraintWithItem:self.lrcView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    [self.view addConstraints:@[cnsT3,cnsB3,cnsL3,cnsR3]];
    
    /** 歌曲列表 */
    self.playListTable = [[UITableView alloc] init];
    self.playListTable.rowHeight = 30;
    self.playListTable.delegate = self;
    self.playListTable.dataSource = self;
    self.playListTable.backgroundColor = [UIColor blackColor];
    self.playListTable.alpha = 0.6;
    
    [self.view addSubview:self.playListTable];
    self.playListTable.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *cnsT4 = [NSLayoutConstraint constraintWithItem:self.playListTable attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleListBtn attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *cnsB4 = [NSLayoutConstraint constraintWithItem:self.playListTable attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.playerConsole attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *cnsL4 = [NSLayoutConstraint constraintWithItem:self.playListTable attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *cnsR4 = [NSLayoutConstraint constraintWithItem:self.playListTable attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    [self.view addConstraints:@[cnsT4,cnsB4,cnsL4,cnsR4]];
    
    /** 按钮移到最前 */
    [self.view bringSubviewToFront:self.titleListBtn];
    [self.view bringSubviewToFront:self.favoriteBtn];
    [self.view bringSubviewToFront:self.backBtn];
    
    /** 播放器 */
    self.audioController = [SYAudioController sharedAudioController];
    self.audioController.delegate = self;
    /** 设定audioPlayer若干代码块 */
    self.audioController.onStateChange = ^(FSAudioStreamState state) {
        switch (state) {
            case kFsAudioStreamRetrievingURL:
                NSLog(@"kFsAudioStreamRetrievingURL");
                break;
            case kFsAudioStreamPaused:
                weakSelf.playerConsole.playing = NO;
                [weakSelf.progressUpdateTimer invalidate];
                weakSelf.progressUpdateTimer = nil;
                break;
            case kFsAudioStreamStopped:
                weakSelf.playerConsole.playing = NO;
                
                [weakSelf.progressUpdateTimer invalidate];
                weakSelf.progressUpdateTimer = nil;
                break;
            case kFsAudioStreamBuffering:
                break;
            case kFsAudioStreamSeeking:
                break;
            case kFsAudioStreamPlaying:
                weakSelf.playerConsole.playing = YES;
                
                if (!weakSelf.progressUpdateTimer) {
                    weakSelf.progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:updateInterval target:weakSelf selector:@selector(updatePlaybackProgress) userInfo:nil repeats:YES];
                }
                
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
            //            [streamInfo appendString:metaData[@"MPMediaItemPropertyArtist"]];
            //            [streamInfo appendString:@" - "];
            [streamInfo appendString:metaData[@"MPMediaItemPropertyTitle"]];
        } else if (metaData[@"StreamTitle"]) {
            [streamInfo appendString:metaData[@"StreamTitle"]];
        }
        
        weakSelf.playerConsole.statusText = streamInfo;
        
    };
    
    if(!self.audioController.isPlaying){
        //        SYSong *model = self.songModelArrary[0];
        //        [self playModel:model];
        weakSelf.playerConsole.stopped = YES;
    }
    
    //    if (!self.progressUpdateTimer) {
    //        self.progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:updateInterval target:self selector:@selector(updatePlaybackProgress) userInfo:nil repeats:YES];
    //    }
}

-(void)reLayoutSubviewsWithAdHeight:(float)height
{
    for (NSLayoutConstraint *cst in self.bannerView.constraints) {
        if (cst.firstAttribute == NSLayoutAttributeHeight) {
            cst.constant = height;
            break;
        }
    }
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
-(void)downloadWithWifiCheckToDir:(NSString *)dirPath onModel:(SYSong *)model withCompletionBlock:(SYDownloadCompletion)completionBlock
{
    __weak typeof(self) weakSelf = self;
    Reachability *wifiChecker = [Reachability reachabilityForInternetConnection];
    if ([wifiChecker isReachableViaWiFi]) {
        [self downloadToDir:dirPath onModel:model withCompletionBlock:completionBlock];
    }else{
        RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:@"取消" action:^{
        }];
        RIButtonItem *okButtonItem = [RIButtonItem itemWithLabel:@"我是土豪继续下载" action:^{
            [weakSelf downloadToDir:dirPath onModel:model withCompletionBlock:completionBlock];
        }];
        
        UIAlertView *wifiAlert = [[UIAlertView alloc] initWithTitle:@"警告!木有WiFi!" message:@"继续下载可能会产生流量费用哦！" cancelButtonItem:cancelButtonItem otherButtonItems:okButtonItem, nil];
        [wifiAlert show];
        [NSTimer scheduledTimerWithTimeInterval:5 target:wifiAlert selector:@selector(dismissAnimated:) userInfo:nil repeats:NO];
    }
}
/** 下载 */
-(void)downloadToDir:(NSString *)dirPath onModel:(SYSong *)model withCompletionBlock:(SYDownloadCompletion)completionBlock
{
    long index = [self.songModelArrary indexOfObject:model];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    __weak typeof(self) weakSelf = self;
    [model prepareDownloadToFile:dirPath onDownloading:^(float progress) {
        SYSongCell *cell = (SYSongCell *)[weakSelf.playListTable cellForRowAtIndexPath:indexPath];
        cell.playListData = model;
    } onComplete:^(BOOL complete) {
        [weakSelf.playListTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
        if (complete) {
            completionBlock();
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"下载失败" message:@"貌似网络不给力呀亲╭(╯3╰)╮" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

-(BOOL)playModel:(SYSong *)model
{
    if(model == nil) return NO;

#warning 更新plist
//    if([model checkPathUpdate:self.playList.lessonTitle]){
//        [self refreshSongModelArrary];
//    }
    if (model.downloadProgress < 1)
    {
        long index = [self.songModelArrary indexOfObject:model];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.playListTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
    }
    
    if (model.downloadProgress >= 1) {
        NSString *mp3Path = model.localPath;
        NSURL *url;
        if([mp3Path hasPrefix:@"/"]){
            url = [NSURL fileURLWithPath:mp3Path];
        }else{
            url = [NSURL URLWithString:mp3Path];
        }
        
        self.audioController.url = url;
        [self.audioController play];
        self.playerConsole.playing = YES;
        
        NSString *lrcPath = [model.localPath stringByReplacingOccurrencesOfString:@"mp3" withString:@"lrc"];
        self.lrcView.lrcFile = lrcPath;
        
        NSArray *ary = [model.name componentsSeparatedByString:@"－"];
        NSString *str = [ary firstObject];
        self.titleListBtn.titleText = [NSString stringWithFormat:@"%@-%@",self.playList.lessonTitle,str];
        
        self.titleListBtn.Opened = NO;
        
//        MPMediaItemArtwork *albumArt = [ [MPMediaItemArtwork alloc] initWithImage: [UIImage imageNamed:@"main_bg"]];
//        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
//        songInfo[MPMediaItemPropertyTitle] = model.name;
//        songInfo[MPMediaItemPropertyArtist] = @"新概念英语";
//        songInfo[MPMediaItemPropertyAlbumTitle] = self.playList.lessonTitle;
//        [songInfo setObject: albumArt forKey:MPMediaItemPropertyArtwork ];
//        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        
        long index = [self.songModelArrary indexOfObject:model];
        self.selectedIndexpath = [NSIndexPath indexPathForRow:index inSection:0];
        
        NSMutableString *t_evnt = [NSMutableString stringWithFormat:@"Song:%@",model.name];
        [MobClick event:@"Playing" label:t_evnt];
        
        return YES;
    }
    
    __weak typeof(self) weakSelf = self;
    if (model.downloading == NO) {
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"取消"];
        RIButtonItem *okItem = [RIButtonItem itemWithLabel:@"下载" action:^{
            NSString *dirPath = [catchePath stringByAppendingPathComponent:weakSelf.playList.lessonTitle];
            [weakSelf downloadWithWifiCheckToDir:dirPath onModel:model withCompletionBlock:^{
            }];
        }];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"本课未下载" message:@"是否下载？" cancelButtonItem:cancelItem otherButtonItems:okItem, nil];
        [alert show];
        [NSTimer scheduledTimerWithTimeInterval:5 target:alert selector:@selector(dismissAnimated:) userInfo:nil repeats:NO];
    }
    
    if (self.selectedIndexpath != nil) {
        SYSong *lastModel = self.songModelArrary[self.selectedIndexpath.row];
        if(lastModel != model){
            [self playModel:lastModel];
        }
        self.titleListBtn.Opened = YES;
    }else{
        //停止
        self.playerConsole.stopped = YES;
        [self.audioController stop];
        self.lrcView.lrcFile = nil;
        self.titleListBtn.Opened = YES;
    }
    
    return NO;
}
/** 重设recordView Frame */
-(void)popOutRecorder:(BOOL)isPopOut
{
    self.recordView.animating = YES;
    
    float x = 0;
    float y = 0;
    float w = 0;
    if (!isPopOut) {
        CGRect pFrame = self.playerConsole.frame;
        CGRect bFrame = self.playerConsole.recordFrame;
        CGRect cFrame = self.recordView.frame;
        
        x = CGRectGetMidX(bFrame) + pFrame.origin.x - CGRectGetMidX(cFrame);
        y = CGRectGetMidY(bFrame) + pFrame.origin.y - CGRectGetMidY(cFrame);
        w = bFrame.size.width / self.recordView.micScale - cFrame.size.width;
    }
    for (NSLayoutConstraint *cns in self.view.constraints) {
        if (cns.firstItem == self.recordView) {
            if (cns.firstAttribute == NSLayoutAttributeCenterX) {
                cns.constant = x;
            }
            if (cns.firstAttribute == NSLayoutAttributeCenterY) {
                cns.constant = y;
            }
            if (cns.firstAttribute == NSLayoutAttributeWidth) {
                cns.constant = w;
            }
        }
    }
}
#pragma mark - IBAction

/** 全部下载按钮按下 */
- (IBAction)favoriteBtnClick {
    __weak typeof(self) weakSelf = self;
    RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:@"取消" action:^{
        weakSelf.downloading = NO;
    }];
    
    SYSong *downloadModel = nil;
    for (SYSong *model in self.songModelArrary) {
        if (model.downloading == NO) {
            downloadModel = model;
            break;
        }
    }
    if (downloadModel != nil) {
        NSString *dirPath = [catchePath stringByAppendingPathComponent:self.playList.lessonTitle];
        RIButtonItem *okButtonItem = [RIButtonItem itemWithLabel:@"下载" action:^{
            [weakSelf downloadWithWifiCheckToDir:dirPath onModel:downloadModel withCompletionBlock:^{
                weakSelf.downloading = YES;
                [weakSelf favoriteBtnClick];
            }];
        }];
        
        if (!self.downloading) {
            UIAlertView *downloadAlert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"全部下载本册吗？" cancelButtonItem:cancelButtonItem otherButtonItems:okButtonItem, nil];
            [downloadAlert show];
        }else{
            [self downloadWithWifiCheckToDir:dirPath onModel:downloadModel withCompletionBlock:^{
                weakSelf.downloading = YES;
                [weakSelf favoriteBtnClick];
            }];
        }
    }else{
        self.downloading = NO;
    }
}
/** 后退按钮按下 */
- (IBAction)backBtnClick {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.audioController stop];
        [self.recordView stop];
    }];
}
#pragma mark - Property
/** 延迟加载播放列表数据 */
-(NSArray *)songModelArrary
{
    if (_songModelArrary == nil) {
        _songModelArrary = self.playList.songs;
    }
    
    return _songModelArrary;
}
-(SYRecordView *)recordView
{
    if (_recordView == nil) {
        _recordView = [SYRecordView recordView];
        [_recordView stop];
        
        [self.view addSubview:_recordView];
        
        _recordView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_recordView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_recordView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_recordView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.6 constant:0]];
        
        NSLayoutConstraint *cns = [NSLayoutConstraint constraintWithItem:_recordView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_recordView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
        [_recordView addConstraint:cns];
        
    }
    return _recordView;
}

-(UIScrollView *)backgroundScroll{
    if (_backgroundScroll == nil) {
        _backgroundScroll = [[SYBackGroundScroll alloc] init];
        _backgroundScroll.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _backgroundScroll;
}
-(void)setSelectedIndexpath:(NSIndexPath *)selectedIndexpath{
    SYSongCell *prevCell = (SYSongCell *)[self.playListTable cellForRowAtIndexPath:_selectedIndexpath];
    [prevCell setSelected:NO];
    _selectedIndexpath = selectedIndexpath;
    SYSongCell *currCell = (SYSongCell *)[self.playListTable cellForRowAtIndexPath:_selectedIndexpath];
    [currCell setSelected:YES];
}
#pragma mark - SYPlayerConsoleDelegate

/** 下一首 */
-(void)playerConsoleNext:(SYPlayerConsole *)console{
    NSIndexPath *newIndexPath = self.selectedIndexpath;
    if (newIndexPath.row < [self.playListTable numberOfRowsInSection:newIndexPath.section] - 1) {
        newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row + 1 inSection:newIndexPath.section];
        [self.playListTable selectRowAtIndexPath:newIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        SYSong *model = self.songModelArrary[newIndexPath.row];
        [self playModel:model];
        self.titleListBtn.Opened = NO;
    }
}
/** 上一首 */
-(void)playerConsolePrev:(SYPlayerConsole *)console{
    NSIndexPath *newIndexPath = self.selectedIndexpath;
    if (newIndexPath.row > 0) {
        newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row - 1 inSection:newIndexPath.section];
        [self.playListTable selectRowAtIndexPath:newIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        SYSong *model = self.songModelArrary[newIndexPath.row];
        [self playModel:model];
        self.titleListBtn.Opened = NO;
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
-(void)playerConsoleListClick:(SYPlayerConsole *)console{
    self.titleListBtn.Opened = !self.titleListBtn.Opened;
}
/** 播放模式改变 */
-(void)playerConsolePlayModeStateChanged:(SYPlayerConsole *)console withModeName:(NSString *)name{
    if (console.playMode == playModeStateSingleSentenceRepeat) {
        self.lrcView.playMode = lrcPlayModeSingleSentence;
    }else{
        self.lrcView.playMode = lrcPlayModeWhole;
    }
}
/** 录音模式改变 */
-(void)playerConsoleRecordingStatusChanged:(SYPlayerConsole *)console
{
    if (console.recording) {
        self.lrcView.playMode = lrcPlayModeSingleSentence;
        [self popOutRecorder:YES];
        self.recordView.animating = NO;
    }else{
        self.lrcView.playMode = lrcPlayModeWhole;
        [self popOutRecorder:NO];
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.recordView.animating = NO;
            [self.recordView stop];
        }];
    }
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
/** 一句播完 */
-(void)lrcView:(SYLrcView *)lrcView sentenceInterval:(float)inteval sentence:(NSString *)sentence time:(float)time
{
    SYSong *model = self.songModelArrary[self.selectedIndexpath.row];
    NSString *title = model.name;
    
    self.playerConsole.playing = NO;
    [self.progressUpdateTimer invalidate];
    self.progressUpdateTimer = nil;
    self.playerConsole.playing = NO;
    [self playerConsolePlayingStatusChanged:self.playerConsole];
    
    __weak typeof(self) weakSelf = self;
    
    [self popOutRecorder:YES];
    [self.recordView startRecordCompletion:^(NSString *recordPath) {
        weakSelf.playerConsole.playing = YES;
        [weakSelf playerConsolePlayingStatusChanged:self.playerConsole];
        [weakSelf.recordView loadSentence:sentence lessonTitle:title duration:inteval];
        
        [lrcView nextSentence:time];
        
        [weakSelf popOutRecorder:NO];
        [UIView animateWithDuration:0.5 animations:^{
            [weakSelf.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            weakSelf.recordView.animating = NO;
            [weakSelf.recordView startPlayCompletion:^{
                if (inteval == 0) {
                    weakSelf.playerConsole.playing = NO;
                    [weakSelf.progressUpdateTimer invalidate];
                    weakSelf.progressUpdateTimer = nil;
                    weakSelf.playerConsole.playing = NO;
                    [weakSelf playerConsolePlayingStatusChanged:weakSelf.playerConsole];
                    
                    [weakSelf.recordView startRecordCompletion:^(NSString *recordPath){
                        [weakSelf.recordView stop];
                        
                        weakSelf.playerConsole.playing = YES;
                        [weakSelf playerConsolePlayingStatusChanged:self.playerConsole];
                        [weakSelf.view bringSubviewToFront:weakSelf.playerConsole];
                    }];
                }
            }];
        }];
    }];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.recordView.animating = NO;
    }];
    
    [self.view bringSubviewToFront:self.recordView];
}
#pragma mark - SYTitleButtonDelegate
/** 播放列表展开/关闭 */
-(void)playListButtonBtnClicked:(SYTitleButton *)playListBtn
{
    for (NSLayoutConstraint *cst in self.view.constraints) {
        if ((cst.firstItem == self.playListTable) && (cst.firstAttribute == NSLayoutAttributeBottom)) {
            cst.constant = playListBtn.isOpened ? 0 : -(self.playerConsole.frame.origin.y - self.playListTable.frame.origin.y);
            [UIView animateWithDuration:0.3 animations:^{
                [self.view layoutIfNeeded];
            }];
            break;
        }
    }
}

#pragma mark - playListTable DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.songModelArrary count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYSongCell *cell = [SYSongCell cellWithTableView:tableView];
    SYSong *model = self.songModelArrary[indexPath.row];
#warning 更新plist
//    if([model checkPathUpdate:self.playList.lessonTitle]){
//        [self refreshSongModelArrary];
//    }

    cell.playListData = model;
    cell.delegate = self;
    
    return cell;
}

#pragma mark - playListTableDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYSong *model = self.songModelArrary[indexPath.row];
    [self playModel:model];
}

#pragma mark - SYSongCellDelegate
-(void)songCellDownloadBtnClick:(SYSongCell *)cell
{
    NSIndexPath *indexPath = [self.playListTable indexPathForCell:cell];
    SYSong *model = self.songModelArrary[indexPath.row];
    
    NSString *dirPath = [catchePath stringByAppendingPathComponent:self.playList.lessonTitle];
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

#pragma mark - dealloc
-(void)dealloc
{
    /** 广点通 */
    self.bannerView.delegate = nil;
    self.bannerView.currentViewController = nil;
    self.bannerView = nil;
//    NSLog(@"%@ dealloc!",NSStringFromClass(self.class));
}
@end
