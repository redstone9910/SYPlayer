//
//  SYSongModel.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-23.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYSongModel.h"

@implementation SYSongModel
/** 通过字典创建 */
+(instancetype)songModelWithDict:(NSDictionary *)dict
{
    return [[self alloc]initWithDict:dict];
}
/** 通过字典初始化 */
-(instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+(NSString *)songModelArrayWithFileNameArray:(NSArray *)nameArray withPlistFileName:(NSString *)plist
{
    NSMutableArray *ret = [NSMutableArray array];
    
    NSBundle *bundle = [NSBundle mainBundle];
    for (NSString *song in nameArray) {
        NSArray *array = [song componentsSeparatedByString:@"mp3"];
        NSString *file = [array firstObject];
//        NSString *path = [bundle pathForResource:song ofType:nil];
//        NSArray *b = [bundle pathsForResourcesOfType:@"mp3" inDirectory:@"NCE2-美音-(MP3+LRC)"];
        NSString *path = [[[bundle resourcePath] stringByAppendingPathComponent:@"第二册"] stringByAppendingPathComponent:song];
        if (path != nil) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            [dict setObject:path forKey:@"mp3URL"];
            [dict setObject:[NSNumber numberWithBool:NO] forKey:@"playing"];
            
            NSArray *a = [file componentsSeparatedByString:@"."];
            NSString *s = [a firstObject];
            [dict setObject:s forKey:@"songName"];
            
            [dict setObject:[NSNumber numberWithInt:0] forKey:@"downloadProgress"];
            [dict setObject:[NSNumber numberWithInt:0] forKey:@"downloading"];
            
            [ret addObject:dict];
        }
    }
    
    NSString *destPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:plist];
    if([ret writeToFile:destPath atomically:YES]) return destPath;
    else return nil;
}
@end
