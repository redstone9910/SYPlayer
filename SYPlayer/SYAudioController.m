//
//  SYAudioController.m
//  SYPlayer
//
//  Created by YinYanhui on 15-4-17.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYAudioController.h"
#import "SYPlaylists.h"
#import "Gloable.h"

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
    }
    return self;
}

-(void)play{
    SYPlaylist *list = self.volumes.playLists[self.volumes.playingIndex];
    SYSong *model = list.songs[list.playingIndex];
    
    if(model == nil) return;

    NSString *urlStr;
    if (model.localPath.length > 0) {
        urlStr = model.localPath;
    }else if(model.url.length > 0){
        urlStr = model.url;
    }else{
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
    [super play];
}
-(void)dealloc{
    SYLog(@"%@ dealloc",NSStringFromClass([self class]));
}
#pragma mark - property
-(SYPlaylists *)volumes{
    if (_volumes == nil) {
        NSString *fileListAll = [[NSBundle mainBundle] pathForResource:@"nec_mp3_file_list" ofType:@"txt"];
        _volumes = [SYPlaylists playListsWithMp3FileList:fileListAll];
    }
    return _volumes;
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
/** 更新播放进度 */
- (void)updatePlaybackProgress
{
    if ([self.sydelegate respondsToSelector:@selector(SYAudioControllerTimerUpdate:)]) {
        [self.sydelegate SYAudioControllerTimerUpdate:self];
    }
}
//        MPMediaItemArtwork *albumArt = [ [MPMediaItemArtwork alloc] initWithImage: [UIImage imageNamed:@"main_bg"]];
//        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
//        songInfo[MPMediaItemPropertyTitle] = model.name;
//        songInfo[MPMediaItemPropertyArtist] = @"新概念英语";
//        songInfo[MPMediaItemPropertyAlbumTitle] = self.playList.volumeTitle;
//        [songInfo setObject: albumArt forKey:MPMediaItemPropertyArtwork ];
//        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];

@end
