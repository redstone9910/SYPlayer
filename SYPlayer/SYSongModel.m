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
-(void)startDownloadToFile:(NSString *)dirPath onDownloading:(MIBSongDownloadingBlock)downloadingBlock onComplete:(MIBSongDownloadCompleteBlock)completeBlock;
@property (strong, nonatomic) MKNetworkOperation *downloadOperation;
@end

@implementation SYSongModel

-(NSString *)mp3URL
{
    if ([_mp3URL hasPrefix:@"/"]) {
        if([[NSFileManager defaultManager]fileExistsAtPath:_mp3URL])
        {
            self.downloading = YES;
            self.downloadProgress = 1;
        }else {
            _mp3URL = @"";
            self.downloading = NO;
            self.downloadProgress = 0;
        }
    }
    return _mp3URL;
}

-(float)downloadProgress
{
    [self mp3URL];
    return _downloadProgress;
}

-(BOOL)isDownloading
{
    [self mp3URL];
    return _downloading;
}
/** 根据歌曲名查找文件 */
-(BOOL)findPath:(NSString *)rootPath
{
    NSString *song = [self.songName stringByAppendingString:@".mp3"];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [[[bundle resourcePath] stringByAppendingPathComponent:rootPath] stringByAppendingPathComponent:song];//查找resource目录
    if([[NSFileManager defaultManager]fileExistsAtPath:path]){
        self.mp3URL = path;
        return YES;
    }else{
        path = [[catchePath stringByAppendingPathComponent:rootPath] stringByAppendingPathComponent:song];//查找沙盒Document目录
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            self.mp3URL = path;
            return YES;
        }
        else
        {
            return NO;
        }
    }
}
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
/** model转dic */
-(NSDictionary *)dictFromSongModel
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setObject:self.mp3URL forKey:@"mp3URL"];
    [dict setObject:[NSNumber numberWithBool:self.isPlaying] forKey:@"playing"];
    [dict setObject:self.songName forKey:@"songName"];
    [dict setObject:[NSNumber numberWithInt:self.downloadProgress] forKey:@"downloadProgress"];
    [dict setObject:[NSNumber numberWithInt:self.isDownloading] forKey:@"downloading"];
    
    return [dict copy];
}
-(void)prepareDownloadToFile:(NSString *)dirPath onDownloading:(MIBSongDownloadingBlock)downloadingBlock onComplete:(MIBSongDownloadCompleteBlock)completeBlock
{
    if ([self.mp3URL isEqualToString:@""]) {
        [MIBServer getLogonMD5WithName:@"wangwu" password:@"ww" fileName:self.songName onComplete:^(NSString *fileURL) {
            if (fileURL == nil)
            {
                completeBlock(NO);
                return;
            }
            self.mp3URL = fileURL;
            [self startDownloadToFile:dirPath onDownloading:downloadingBlock onComplete:completeBlock];
        }];
    }else{
        [self startDownloadToFile:dirPath onDownloading:downloadingBlock onComplete:completeBlock];
    }
}

-(void)startDownloadToFile:(NSString *)dirPath onDownloading:(MIBSongDownloadingBlock)downloadingBlock onComplete:(MIBSongDownloadCompleteBlock)completeBlock
{
    __weak SYSongModel * weakSelf = self;
    
    self.downloading = YES;
    downloadingBlock(0);
    
    NSString *urlStr = [self.mp3URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString *downloadPath = [[dirPath stringByAppendingPathComponent:self.songName] stringByAppendingString:@".mp3.download"];
    
    self.downloadOperation = [[[MKDownloader alloc] init] downloadFatAssFileFrom:urlStr toFile:downloadPath];
    [self.downloadOperation onDownloadProgressChanged:^(double progress) {
        self.downloadProgress = progress;
        downloadingBlock(progress);
    }];
    
    [self.downloadOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        //重命名文件
        NSString *mp3Path = [downloadPath stringByReplacingOccurrencesOfString:@".download" withString:@""];
        [[NSFileManager defaultManager] copyItemAtPath:downloadPath toPath:mp3Path error:nil];
        if ([[NSFileManager defaultManager] fileExistsAtPath:mp3Path]) {
            [[NSFileManager defaultManager] removeItemAtPath:downloadPath error:nil];
            
            weakSelf.downloadProgress = 1;
            weakSelf.mp3URL = mp3Path;
            //下载LRC文件
            NSString *lrcURL = [urlStr stringByReplacingOccurrencesOfString:@".mp3" withString:@".lrc"];
            NSString *lrcPath = [mp3Path stringByReplacingOccurrencesOfString:@".mp3" withString:@".lrc"];
            weakSelf.downloadOperation = [[[MKDownloader alloc] init] downloadFatAssFileFrom:lrcURL toFile:lrcPath];
            completeBlock(YES);
        } else {
            completeBlock(NO);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        weakSelf.downloadProgress = 0;
        weakSelf.downloading = NO;
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
