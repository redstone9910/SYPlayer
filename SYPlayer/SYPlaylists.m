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
+(SYPlaylists *)playListsWithMp3FileList:(NSString *)file toPath:(NSString *)path
{
    NSString *destPath = [catchePath stringByAppendingPathComponent:path];
    SYPlaylists *playLists = [[SYPlaylists alloc] init];
    playLists.path = destPath;
    if ([playLists load]) {
        return playLists;
    }
    
    NSString *fileList = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    NSArray *lineArray = [fileList componentsSeparatedByString:@"\n"];
    
    NSMutableArray *listArray = [NSMutableArray array];//plist文件
    SYPlaylist *playList = [[SYPlaylist alloc] init];
    NSMutableArray *songs = [NSMutableArray array];//暂存文件名列表
    for (NSString *line in lineArray) {
        if ([line hasPrefix:@"第"] && [line hasSuffix:@"册"]) {//册标题
            if (playList.lessonTitle != nil) //新一册开始
            {
                playList.songs = [songs copy];
                songs = [NSMutableArray array];//创建新文件名数组
                [listArray addObject:playList];//上一册添加进plist文件
                playList = [[SYPlaylist alloc] init];//创建新文件
            }
            playList.lessonTitle = line;
            playList.playingIndex = 0;
            playList.prevIndex = 0;
        }
        else//文件名
        {
            if ([line hasSuffix:@"mp3"]) {//mp3文件
                [songs addObject:[SYSong songWithFileName:line inDir:playList.lessonTitle]];//mp3文件添加进暂存数组
            }
        }
    }
    playList.songs = [songs copy];
    [listArray addObject:playList];//上一册添加进plist文件
    
    playLists.playingIndex = 0;
    playLists.playLists = [listArray copy];
    
    if([playLists save]) return playLists;
    else return nil;
}

+(instancetype)playlistsWithDict:(NSDictionary *)dict{
    return [self objectWithKeyValues:dict];
}

-(NSDictionary *)toDict{
    return [self keyValues];
}
-(BOOL)save{
    if (self.path == nil) {
        return NO;
    }
    return [[self toDict] writeToFile:self.path atomically:YES];
}
-(BOOL)load{
    if (self.path == nil) {
        return NO;
    }
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:self.path];
    if (dict == nil) {
        return NO;
    }
    [self setKeyValues:dict];
    
    return YES;
}
@end
