//
//  SYPlaylists.m
//  SYPlayer
//
//  Created by YinYanhui on 15-5-24.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYPlaylists.h"
#import "SYPlaylist.h"
#import "SYSong.h"
#import "MJExtension.h"
#import "Gloable.h"

@implementation SYPlaylists
/** playLists 数组类型为 SYPlaylist */
+ (NSDictionary *)objectClassInArray
{
    return @{@"playLists" : [SYPlaylist class]};
}

/** 通过文件列表创建列表Plist文件 */
+(SYPlaylists *)playListsWithMp3FileList:(NSString *)file{
    return [self playListsWithMp3FileList:file toPath:nil];
}
/** 通过文件列表创建列表Plist文件 */
+(SYPlaylists *)playListsWithMp3FileList:(NSString *)file toPath:(NSString *)path
{
    NSString *destPath = path;
    if (destPath) {
        destPath = [catchePath stringByAppendingPathComponent:destPath];
    }
    SYPlaylists *playLists = [[SYPlaylists alloc] init];
    playLists.path = destPath;
    if ([playLists load]) {
        playLists.path = destPath;
        return playLists;
    }
    
    NSString *fileList = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    NSArray *lineArray = [fileList componentsSeparatedByString:@"\n"];
    
    NSMutableArray *listArray = [NSMutableArray array];//plist文件
    SYPlaylist *playList = [[SYPlaylist alloc] init];
    NSMutableArray *songs = [NSMutableArray array];//暂存文件名列表
    int volumeIndex = 1;
    for (NSString *line in lineArray) {
        if ([line hasPrefix:@"第"] && [line hasSuffix:@"册"]) {//册标题
            if (playList.volumeTitle != nil) //新一册开始
            {
                playList.volumeIndex = volumeIndex ++;
                playList.songs = [songs copy];
                songs = [NSMutableArray array];//创建新文件名数组
                
                [listArray addObject:playList];//上一册添加进plist文件
                playList = [[SYPlaylist alloc] init];//创建新文件
            }
            playList.volumeTitle = line;
            playList.playingIndex = 0;
            playList.prevIndex = 0;
        }
        else//文件名
        {
            if ([line hasSuffix:@"mp3"]) {//mp3文件
                [songs addObject:[SYSong songWithFileName:line inDir:playList.volumeTitle]];//mp3文件添加进暂存数组
            }
        }
    }
    playList.volumeIndex = volumeIndex ++;
    playList.songs = [songs copy];
    [listArray addObject:playList];//上一册添加进plist文件
    
    playLists.playingIndex = 0;
    playLists.playLists = [listArray copy];
    
    if([playLists save]) return playLists;
    else return nil;
}
/** 从字典创建对象 */
+(instancetype)playlistsWithDict:(NSDictionary *)dict{
    return [self objectWithKeyValues:dict];
}
/** 字典转模型 */
-(NSDictionary *)toDict{
    return [self keyValues];
}
/** 保存到文件 */
-(BOOL)save{
    return [[self toDict] writeToFile:self.path atomically:YES];
}
/** 从文件加载 */
-(BOOL)load{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:self.path];
    if (dict == nil) {
        return NO;
    }
    [self setKeyValues:dict];
    
    if ([self updateCheck]) {
        [self save];
    }
    return YES;
}
/** 检查文件本地路径是否有更新 */
-(BOOL)updateCheck{
    BOOL update = NO;
    for (SYPlaylist *list in self.playLists) {
        if ([list updateCheck]) {
            update = YES;
        }
    }
    return update;
}
/** 正在播放的列表 */
-(SYPlaylist *)playingList{
    return self.playLists[self.playingIndex];
}
/** 正在播放的曲目 */
-(SYSong *)playingSong{
    return [[self playingList] playingSong];
}
#pragma mark - property
/** load/save路径 */
-(NSString *)path{
    if (_path == nil) {
        _path = [catchePath stringByAppendingPathComponent:@"nce_root.plist"];
    }
    return _path;
}
/** 设定正在播放序号并越界检查 */
-(void)setPlayingIndex:(long)playingIndex{
    if (playingIndex > self.playLists.count - 1) {
        playingIndex = 0;
    }else if(playingIndex < 0){
        playingIndex = self.playLists.count - 1;
    }
    
    _playingIndex = playingIndex;
}
@end
