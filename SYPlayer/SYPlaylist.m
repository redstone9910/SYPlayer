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
/** 通过字典创建 */
-(instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.lessonTitle = dict[@"lessonTitle"];
        NSNumber * playingIndex= dict[@"playingIndex"];
        self.playingIndex = playingIndex.longValue;
        NSNumber * prevIndex= dict[@"prevIndex"];
        self.prevIndex = prevIndex.longValue;
        NSArray *songDictArray = dict[@"songs"];
        NSMutableArray *songs = [NSMutableArray array];
        for (NSDictionary *dict in songDictArray) {
            SYSong *model = [SYSong songModelWithDict:dict];
            [songs addObject:model];
        }
        self.songs = [songs copy];
    }
    return self;
}
-(NSDictionary *)toDict{
    return [self keyValues];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"lessonTitle"] = self.lessonTitle;
    dict[@"playingIndex"] = [NSNumber numberWithLong:self.playingIndex];
    dict[@"prevIndex"] = [NSNumber numberWithLong:self.prevIndex];
    NSMutableArray *songs = [NSMutableArray array];
    for (SYSong *song in self.songs) {
        NSDictionary *dict = [song toDict];
        [songs addObject:dict];
    }
    dict[@"songs"] = [songs copy];
    return dict;
}

@end
