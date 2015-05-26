//
//  SYPlaylist.m
//  SYPlayer
//
//  Created by YinYanhui on 15-4-2.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYPlaylist.h"
#import "Gloable.h"
#import "SYSong.h"
#import "MJExtension.h"

@interface SYPlaylist ()

@end

@implementation SYPlaylist
/** songs 数组类型为 SYSong */
+ (NSDictionary *)objectClassInArray
{
    return @{@"songs" : [SYSong class]};
}
/** 通过字典创建 */
+(instancetype)playListWithDict:(NSDictionary *)dict
{
    return[self objectWithKeyValues:dict];
}
/** 模型转字典 */
-(NSDictionary *)toDict{
    return [self keyValues];
}

/** 检查列表中文件本地路径是否有更新 */
-(BOOL)updateCheck
{
    if (self.songs.count < self.playingIndex + 1) {
        return NO;
    }
    BOOL update = NO;
    for (SYSong *song in self.songs) {
        if ([song updeteCheckInDir:self.volumeTitle]) {
            update = YES;
        }
    }

    return update;
}
/** 正在播放的曲目 */
-(SYSong *)playingSong{
    if (self.songs.count <= 0) {
        self.playingIndex = 0;
        return nil;
    }

    return self.songs[self.playingIndex];
}
/** 设定正在播放序号并越界检查 */
-(void)setPlayingIndex:(long)playingIndex{
    if (playingIndex > self.songs.count - 1) {
        playingIndex = 0;
    }else if(playingIndex < 0){
        playingIndex = self.songs.count - 1;
    }
    
    _playingIndex = playingIndex;
}
@end
