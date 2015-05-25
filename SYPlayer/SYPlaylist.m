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
        if ([song updeteCheckInDir:self.lessonTitle]) {
            update = YES;
        }
    }

    return update;
}
@end
