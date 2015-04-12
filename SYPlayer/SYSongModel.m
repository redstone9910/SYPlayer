//
//  SYSongModel.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-23.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYSongModel.h"
#import "MIBServer.h"
#import "MKDownloader.h"
#import "Gloable.h"

@interface SYSongModel ()
/** 开始下载 */
-(void)startDownload:(MIBSongDownloadingBlock)downloadingBlock onComplete:(MIBSongDownloadCompleteBlock)completeBlock;
@property (strong, nonatomic) MKNetworkOperation *downloadOperation;
@end

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

-(void)prepareDownload:(MIBSongDownloadingBlock)downloadingBlock onComplete:(MIBSongDownloadCompleteBlock)completeBlock
{
    if ([self.mp3URL isEqualToString:@""]) {
        [MIBServer getLogonMD5WithName:@"wangwu" password:@"ww" fileName:self.songName onComplete:^(NSString *filePath) {
            self.mp3URL = filePath;
            [self startDownload:downloadingBlock onComplete:completeBlock];
        }];
    }else{
        [self startDownload:downloadingBlock onComplete:completeBlock];
    }
}

-(void)startDownload:(MIBSongDownloadingBlock)downloadingBlock onComplete:(MIBSongDownloadCompleteBlock)completeBlock
{
    __weak SYSongModel * weakSelf = self;
    
    self.downloading = YES;
    downloadingBlock(0);
    
    NSString *urlStr = [self.mp3URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#warning 下载到"第x册"目录。更新plist文件（播放时找不到）。
    NSString *downloadPath = [[catchePath stringByAppendingPathComponent:self.songName] stringByAppendingString:@".mp3"];
    self.downloadOperation = [[[MKDownloader alloc] init] downloadFatAssFileFrom:urlStr toFile:downloadPath];
    [self.downloadOperation onDownloadProgressChanged:^(double progress) {
        self.downloadProgress = progress;
        downloadingBlock(progress);
    }];
    
    [self.downloadOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        weakSelf.downloadProgress = 1;
        completeBlock(YES);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        weakSelf.downloadProgress = 0;
        completeBlock(NO);
    }];
}
+(NSString *)songModelArrayWithFileNameArray:(NSArray *)nameArray withPlistFileName:(NSString *)plist atPath:(NSString *)rootPath
{
    NSMutableArray *ret = [NSMutableArray array];
    
    NSBundle *bundle = [NSBundle mainBundle];
    for (NSString *song in nameArray) {
        NSArray *array = [song componentsSeparatedByString:@"mp3"];
        NSString *file = [array firstObject];
        int downloading = 0;
        float downloadProgress = 0;
        NSString *path = [[[bundle resourcePath] stringByAppendingPathComponent:rootPath] stringByAppendingPathComponent:song];//查找resource目录
        if([[NSFileManager defaultManager]fileExistsAtPath:path])
        {
            downloading = 1;
            downloadProgress = 1; 
        }
        else
        {
            path = [[catchePath stringByAppendingPathComponent:rootPath] stringByAppendingPathComponent:song];//查找沙盒Document目录
            if ([[NSFileManager defaultManager] fileExistsAtPath:path])
            {
                downloading = 1;
                downloadProgress = 1;
            }
            else
            {
                path = @"";
            }
        }
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        [dict setObject:path forKey:@"mp3URL"];
        
        [dict setObject:[NSNumber numberWithBool:NO] forKey:@"playing"];
        
        NSArray *a = [file componentsSeparatedByString:@"."];
        NSString *s = [a firstObject];
        [dict setObject:s forKey:@"songName"];
        
        [dict setObject:[NSNumber numberWithInt:downloadProgress] forKey:@"downloadProgress"];
        [dict setObject:[NSNumber numberWithInt:downloading] forKey:@"downloading"];
        
        [ret addObject:dict];
    }
    
    NSString *destPath = [catchePath stringByAppendingPathComponent:plist];
    if([ret writeToFile:destPath atomically:YES]) return destPath;
    else return nil;
}
@end
