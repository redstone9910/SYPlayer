//
//  SYPlaylists.h
//  SYPlayer
//
//  Created by YinYanhui on 15-5-24.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//  存放所有播放列表

#import <Foundation/Foundation.h>
#import "SYPlaylist.h"
#import "SYSong.h"

@interface SYPlaylists : NSObject
/** 播放列表数组 */
@property (nonatomic,strong) NSArray * playLists;
/** 正在播放的列表 */
@property (nonatomic,assign) long playingIndex;
/** 总表保存路径 */
@property (nonatomic,copy) NSString * path;

/** 通过文件列表创建列表Plist文件 */
+(SYPlaylists *)playListsWithMp3FileList:(NSString *)file toPath:(NSString *)path;
/** 通过文件列表创建列表Plist文件 */
+(SYPlaylists *)playListsWithMp3FileList:(NSString *)file;

/** 实例化对象并从字典初始化 */
+(instancetype)playlistsWithDict:(NSDictionary *)dict;
/** 转成字典 */
-(NSDictionary *)toDict;
/** 保存到文件 */
-(BOOL)save;
/** 从文件加载 */
-(BOOL)load;
/** 检查列表中文件本地路径是否有更新 */
-(BOOL)updateCheck;
/** 正在播放的列表 */
-(SYPlaylist *)playingList;
/** 正在播放的曲目 */
-(SYSong *)playingSong;
@end
