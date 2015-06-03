//
//  SYAuthor.m
//  SYPlayer
//
//  Created by YinYanhui on 15-5-24.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYAuthor.h"
#import "SYAlbum.h"
#import "SYSong.h"
#import "MJExtension.h"
#import "Gloable.h"
#import "SYCatcheTool.h"

@interface SYAuthor ()
@end

@implementation SYAuthor
/** albums 数组类型为 SYAlbum */
+ (NSDictionary *)objectClassInArray
{
    return @{@"albums" : [SYAlbum class]};
}
/** 通过文件列表创建列表Plist文件 */
+(SYAuthor *)authorWithMp3FileList:(NSString *)file{
    return [self authorWithMp3FileList:file toPath:nil];
}
/** 通过文件列表创建列表Plist文件 */
+(SYAuthor *)authorWithMp3FileList:(NSString *)file toPath:(NSString *)path
{
    NSString *destPath = path;
    if (destPath) {
        destPath = [catchePath stringByAppendingPathComponent:destPath];
    }
    SYAuthor *author = [[SYAuthor alloc] init];
    author.playingIndex = 0;
    author.name = @"新概念英语";
    
    author.path = destPath;
    if ([author load]) {
        author.path = destPath;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if ([author updateCheck]) {
                [author save];
//                [author load];
            }
        });
        return author;
    }
    
    NSString *fileList = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    NSArray *lineArray = [fileList componentsSeparatedByString:@"\n"];
    
    NSMutableArray *listArray = [NSMutableArray array];//plist文件
    SYAlbum *album = [[SYAlbum alloc] init];
    NSMutableArray *songs = [NSMutableArray array];//暂存文件名列表
    long index = 1;
    for (NSString *line in lineArray) {
        if ([line hasPrefix:@"第"] && [line hasSuffix:@"册"]) {//册标题
            if (album.name.length) //新一册开始
            {
                album.aindex = index ++;
                album.songs = [songs copy];
                album.authorName = author.name;
                songs = [NSMutableArray array];//创建新文件名数组
                
                [listArray addObject:album];//上一册添加进plist文件
                album = [[SYAlbum alloc] init];//创建新文件
            }
            album.name = line;
            album.playingIndex = 0;
            album.prevIndex = 0;
        }
        else//文件名
        {
            if ([line hasSuffix:@"mp3"]) {//mp3文件
                SYSong *song = [SYSong songWithFileName:line inDir:album.name];
                song.authorName = author.name;
                song.albumName = album.name;
                [songs addObject:song];//mp3文件添加进暂存数组
            }
        }
    }
    album.aindex = index ++;
    album.songs = [songs copy];
    album.authorName = author.name;
    [listArray addObject:album];//上一册添加进plist文件
    
    author.albums = [listArray copy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([author updateCheck]) {
            [author save];
            [author load];
        }
    });
    return author;
}
/** 从字典创建对象 */
+(instancetype)authorWithDict:(NSDictionary *)dict{
    return [self instanceWithDict:dict];
}
-(instancetype)init{
    if (self = [super init]) {
        self.path = [NSString string];
        self.self_id = 1;
    }
    return self;
}
/** 保存到文件 */
-(BOOL)save{
    return [SYCatcheTool insertData:self withSubdatas:YES];
//    return [[self toDict] writeToFile:self.path atomically:YES];
}
/** 从文件加载 */
-(BOOL)load{
    NSArray *datas = [SYCatcheTool loadAuthor:self];
    SYAuthor *author = [datas lastObject];
    NSDictionary *dict = [author toDict];
//    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:self.path];
    if (dict == nil) {
        return NO;
    }
    [self setKeyValues:dict];
    
    return YES;
}
/** 检查文件本地路径是否有更新 */
-(BOOL)updateCheck{
    BOOL update = NO;
    for (SYAlbum *album in self.albums) {
        if ([album updateCheck]) {
            update = YES;
        }
    }
    [self fetchLRCs];
    return update;
}
/** 获取所有LRC文件 */
-(void)fetchLRCs{
    for (SYAlbum *album in self.albums) {
        for (SYSong *song in album.songs) {
            if (song.lrcPath.length == 0) {
                [song fetchLRCToDir:album.name complete:^(BOOL success) {
                    if (success) {
                        SYLog(@"Success at %@ - %@",album.name,song.name);
                        [self fetchLRCs];
                    }else{
                        SYLog(@"Failed at %@ - %@",album.name,song.name);
                    }
                }];
                return;
            }
        }
    }
    [self save];
}
/** 正在播放的列表 */
-(SYAlbum *)playingAlbum{
    return self.albums[self.playingIndex];
}
/** 正在播放的曲目 */
-(SYSong *)playingSong{
    return [[self playingAlbum] playingSong];
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
    if (playingIndex > self.albums.count - 1) {
        playingIndex = 0;
    }else if(playingIndex < 0){
        playingIndex = self.albums.count - 1;
    }
    
    _playingIndex = playingIndex;
}
@end
