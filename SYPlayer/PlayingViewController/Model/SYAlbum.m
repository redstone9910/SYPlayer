//
//  SYAlbum.m
//  SYPlayer
//
//  Created by YinYanhui on 15-4-2.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "Gloable.h"
#import "SYAuthor.h"
#import "SYAlbum.h"
#import "SYSong.h"

@interface SYAlbum ()
@end

static NSOperationQueue * queue;

@implementation SYAlbum
/** songs 数组类型为 SYSong */
+ (NSDictionary *)objectClassInArray
{
    return @{@"songs" : [SYSong class]};
}
/** 通过字典创建 */
+(instancetype)albumWithDict:(NSDictionary *)dict
{
    return [self instanceWithDict:dict];
}
/** 初始化 */
-(instancetype)init{
    if (self = [super init]) {
    }
    return self;
}
/** 检查列表中文件本地路径是否有更新 */
-(BOOL)updateCheck
{
    if (queue == nil) {
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:1];
    }
    
    if (self.songs.count < self.playingIndex + 1) {
        return NO;
    }
    BOOL update = NO;
    for (SYSong *song in self.songs) {
        if ([song updeteCheckInDir:self.name]) {
            update = YES;
        }
        if (song.url.length == 0) {
            [queue addOperationWithBlock:^{
                [song fetchURL:^(BOOL success) {
                    if (success) {
//                        SYLog(@"%@-%@ success",self.name,song.name);
                    }else{
                        
                        SYLog(@"%@-%@ failed",self.name,song.name);
                    }
                }];
            }];
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
