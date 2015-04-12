//
//  SYPlayListModel.m
//  SYPlayer
//
//  Created by YinYanhui on 15-4-2.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYPlayListModel.h"
#import "Gloable.h"

@interface SYPlayListModel ()

@end

@implementation SYPlayListModel
/** 通过字典创建 */
-(instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
+(instancetype)playListWithDict:(NSDictionary *)dict
{
    return[[self alloc]initWithDict:dict];
}
/** 通过文件列表创建列表Plist文件 */
+(NSString *)playListArrayFileWithMp3FileList:(NSString *)file withPlistFileName:(NSString *)plist
{
    NSString *fileList = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    NSArray *lineArray = [fileList componentsSeparatedByString:@"\n"];
    
    NSMutableArray *listArray = [NSMutableArray array];//plist文件
    NSMutableDictionary *playListDict = [NSMutableDictionary dictionary];
    NSMutableArray *songList = [NSMutableArray array];//暂存文件名列表
    for (NSString *line in lineArray) {
        if ([line hasPrefix:@"第"] && [line hasSuffix:@"册"]) {//册标题
            if ([playListDict objectForKey:@"lessonTitle"] != nil) //新一册开始
            {
                [playListDict setObject:songList forKey:@"songList"];
                songList = [NSMutableArray array];//创建新文件名数组
                [listArray addObject:playListDict];//上一册添加进plist文件
                playListDict = [NSMutableDictionary dictionary];//创建新文件
            }
            [playListDict setObject:line forKey:@"lessonTitle"];//标题添加
        }
        else//文件名
        {
            if ([line hasSuffix:@"mp3"]) {//mp3文件
                [songList addObject:line];//mp3文件名添加进暂存数组
            }
        }
    }
    [playListDict setObject:songList forKey:@"songList"];
    [listArray addObject:playListDict];//上一册添加进plist文件
    
    NSString *destPath = [catchePath stringByAppendingPathComponent:plist];
    if([listArray writeToFile:destPath atomically:YES]) return destPath;
    else return nil;
}

@end
