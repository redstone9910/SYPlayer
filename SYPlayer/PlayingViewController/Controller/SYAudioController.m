//
//  SYAudioController.m
//  SYPlayer
//
//  Created by YinYanhui on 15-4-17.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "SYAudioController.h"
#import "SYAuthor.h"
#import "Gloable.h"
#import "SYMediaInfo.h"

#define updateInterval 0.1

@interface SYAudioController ()
/** 更新播放进度定时器 */
@property (nonatomic,strong) NSTimer *progressUpdateTimer;
@end

@implementation SYAudioController
/** 单例 */
+(instancetype)sharedAudioController
{
    static SYAudioController *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(instancetype)init{
    if (self = [super init]) {
        self.stopped = YES;
        [self setupAudioController];
    }
    return self;
}

/** 开始播放 */
-(void)startPlay{
    SYAlbum *album = self.author.albums[self.author.playingIndex];
    SYSong *model = album.songs[album.playingIndex];
    
    if(model == nil) return;
    
    NSString *urlStr;
    if (model.localPath.length > 0) {
        urlStr = model.localPath;
    }else if(model.url.length > 0){
        urlStr = model.url;
    }else{
        [model fetchURL:^(BOOL success) {
            if (success) {
                if ([self.sydelegate respondsToSelector:@selector(SYAudioControllerFetchURLSuccess:)]) {
                    [self.sydelegate SYAudioControllerFetchURLSuccess:self];
                }
                [self.author save];
                [self startPlay];
            }else{
                if ([self.sydelegate respondsToSelector:@selector(SYAudioControllerFetchURLFailed:)]) {
                    [self.sydelegate SYAudioControllerFetchURLFailed:self];
                }
            }
        }];
        if ([self.sydelegate respondsToSelector:@selector(SYAudioControllerFetchingURL:)]) {
            [self.sydelegate SYAudioControllerFetchingURL:self];
        }
        if (self.isPlaying) {
            [self changePlayPauseStatus];
        }
        return;
    }
    
    NSURL *url;
    if([urlStr hasPrefix:@"/"]){
        url = [NSURL fileURLWithPath:urlStr];
    }else{
        urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        url = [NSURL URLWithString:urlStr];
    }
    
    self.url = url;
    
    if ([self.sydelegate respondsToSelector:@selector(SYAudioControllerWillPlay:)]) {
        [self.sydelegate SYAudioControllerWillPlay:self];
    }
    self.playing = NO;
    [self play];
}

-(void)dealloc{
    SYLog(@"%@ dealloc",NSStringFromClass([self class]));
}
/** 更新播放进度 */
- (void)updatePlaybackProgress
{
    if ([self.sydelegate respondsToSelector:@selector(SYAudioControllerTimerUpdate:)]) {
        [self.sydelegate SYAudioControllerTimerUpdate:self];
    }
}
/** 播放暂停控制 */
-(void)changePlayPauseStatus{
    if (self.stopped) {
        [self startPlay];
    }else{
        [self pause];
    }
}
/** 设定audioController工况处理 */
-(void)setupAudioController{
    __weak typeof(self) weakSelf = self;
    self.onStateChange = ^(FSAudioStreamState state) {
        SYAudioController *audioController = weakSelf;
        SYAuthor *author = weakSelf.author;
        switch (state) {
            case kFsAudioStreamPlaying:
            {
                SYLog(@"Playing");
                audioController.playing = YES;
                
                if ([weakSelf.sydelegate respondsToSelector:@selector(SYAudioControllerPlaying:)]) {
                    [weakSelf.sydelegate SYAudioControllerPlaying:weakSelf];
                }
                break;
            }
            case kFsAudioStreamPaused:
            {
                SYLog(@"Paused");
                audioController.playing = NO;
                if ([weakSelf.sydelegate respondsToSelector:@selector(SYAudioControllerPause:)]) {
                    [weakSelf.sydelegate SYAudioControllerPause:weakSelf];
                }
                
                break;
            }
            case kFsAudioStreamStopped:
                SYLog(@"Stopped");
                audioController.stopped = YES;
                if ([weakSelf.sydelegate respondsToSelector:@selector(SYAudioControllerStop:)]) {
                    [weakSelf.sydelegate SYAudioControllerStop:weakSelf];
                }
                
                break;
            case kFsAudioStreamPlaybackCompleted:
                SYLog(@"kFsAudioStreamPlaybackCompleted");
                [author playingAlbum].playingIndex ++;
                [audioController startPlay];
                if ([weakSelf.sydelegate respondsToSelector:@selector(SYAudioControllerPlaybackComplete:)]) {
                    [weakSelf.sydelegate SYAudioControllerPlaybackComplete:weakSelf];
                }
                break;
            case kFsAudioStreamSeeking:
                [weakSelf.progressUpdateTimer invalidate];
                weakSelf.progressUpdateTimer = nil;
                if ([weakSelf.sydelegate respondsToSelector:@selector(SYAudioControllerSeeking:)]) {
                    [weakSelf.sydelegate SYAudioControllerSeeking:weakSelf];
                }
                break;
            case kFsAudioStreamBuffering:
                if ([weakSelf.sydelegate respondsToSelector:@selector(SYAudioControllerBuffering:)]) {
                    [weakSelf.sydelegate SYAudioControllerBuffering:weakSelf];
                }
                SYLog(@"kFsAudioStreamBuffering");
                break;
            case kFsAudioStreamFailed:
                SYLog(@"kFsAudioStreamFailed");
                break;
            case kFsAudioStreamRetrievingURL:
                SYLog(@"kFsAudioStreamRetrievingURL");
                break;
            case kFsAudioStreamRetryingStarted:
                SYLog(@"kFsAudioStreamRetryingStarted");
                break;
            case kFsAudioStreamRetryingSucceeded:
                SYLog(@"kFsAudioStreamRetryingSucceeded");
                break;
            case kFsAudioStreamRetryingFailed:
                SYLog(@"kFsAudioStreamRetryingFailed");
                break;
            default:
                break;
        }
    };
    
    self.onFailure = ^(FSAudioStreamError error, NSString *errorDescription) {
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
    
    self.onMetaDataAvailable = ^(NSDictionary *metaData) {
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
        
        SYMediaInfo *info = [[SYMediaInfo alloc] init];
        if (metaData[@"MPMediaItemPropertyArtist"] &&
            metaData[@"MPMediaItemPropertyTitle"]) {
            
            info.Artist = metaData[@"MPMediaItemPropertyArtist"];
            info.Title = metaData[@"MPMediaItemPropertyTitle"];
        } else if (metaData[@"StreamTitle"]) {
            info.Title = metaData[@"StreamTitle"];
        }
        
        if ([weakSelf.sydelegate respondsToSelector:@selector(SYAudioController:mediaInfoLoaded:)]) {
            [weakSelf.sydelegate SYAudioController:weakSelf mediaInfoLoaded:info];
        }
    };
}

#pragma mark - property
-(SYAuthor *)author{
    if (_author == nil) {
        NSString *fileListAll = [[NSBundle mainBundle] pathForResource:@"nec_mp3_file_list" ofType:@"txt"];
        _author = [SYAuthor authorWithMp3FileList:fileListAll];
    }
    return _author;
}
-(void)setPlaying:(BOOL)playing{
    _playing = playing;
    _stopped = NO;
    if (_playing) {
        if (!self.progressUpdateTimer) {
            self.progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:updateInterval target:self selector:@selector(updatePlaybackProgress) userInfo:nil repeats:YES];
        }
    }else{
        [self.progressUpdateTimer invalidate];
        self.progressUpdateTimer = nil;
    }
}
-(void)setStopped:(BOOL)stopped{
    _stopped = stopped;
    if (_stopped) {
        _playing = NO;
        [self.progressUpdateTimer invalidate];
        self.progressUpdateTimer = nil;
    }
}
//        MPMediaItemArtwork *albumArt = [ [MPMediaItemArtwork alloc] initWithImage: [UIImage imageNamed:@"main_bg"]];
//        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
//        songInfo[MPMediaItemPropertyTitle] = model.name;
//        songInfo[MPMediaItemPropertyArtist] = @"新概念英语";
//        songInfo[MPMediaItemPropertyAlbumTitle] = self.album.name;
//        [songInfo setObject: albumArt forKey:MPMediaItemPropertyArtwork ];
//        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];

@end
