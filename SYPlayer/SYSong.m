//
//  SYSong.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-23.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYSong.h"
#import "MIBServer.h"
#import "MKDownloader.h"
#import "AFNetworking.h"
#import "Gloable.h"
#import "MJExtension.h"

@interface SYSong ()
/** 开始下载 */
@property (strong, nonatomic) MKNetworkOperation *downloadOperation;
@end

@implementation SYSong
@synthesize localPath = _localPath;

/** 查找MP3文件并创建对象 */
+(SYSong *)songWithFileName:(NSString *)name inDir:(NSString *)dir{
    SYSong *song = [[SYSong alloc] init];
    
    NSArray *nameArray = [name componentsSeparatedByString:@"."];
    NSString *nameS = [nameArray firstObject];
    nameS = [nameS stringByReplacingOccurrencesOfString:@"." withString:@""];
    song.name = nameS;
    
    song.downloadProgress = 0;
    song.downloading = NO;
    [song updeteCheckInDir:dir];
    [song url];
    
    return song;
}
/** 通过字典创建 */
+(instancetype)songModelWithDict:(NSDictionary *)dict
{
    return [self objectWithKeyValues:dict];
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
-(NSDictionary *)toDict
{
    return [self keyValues];
}

/** 检查本地文件路径是否有更新 YES:有更新 NO:无更新 */
-(BOOL)updeteCheckInDir:(NSString *)dir{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.localPath]) {
        return NO;
    }
    
    /** 文件不存在，按照dir目录查找 */
    NSString *name = [self.name stringByAppendingString:@".mp3"];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *sPath = [[[bundle resourcePath] stringByAppendingPathComponent:dir] stringByAppendingPathComponent:name];//查找resource目录
    if(![[NSFileManager defaultManager]fileExistsAtPath:sPath]){
        sPath = [[catchePath stringByAppendingPathComponent:dir] stringByAppendingPathComponent:name];//查找沙盒Document目录
        if(![[NSFileManager defaultManager] fileExistsAtPath:sPath])
        {
            sPath = @"";
        }
    }
    
    if (sPath.length > 0) {
        self.downloading = NO;
        self.downloadProgress = 1;
    }
    if(![self.localPath isEqualToString:sPath]){
        self.localPath = sPath;
        return YES;
    }else{
        return NO;
    }
}

-(void)prepareDownloadToFile:(NSString *)dirPath onDownloading:(MIBSongDownloadingBlock)downloadingBlock onComplete:(MIBSongDownloadCompleteBlock)completeBlock
{
    if ([self.url isEqualToString:@""]) {
        [MIBServer getLogonMD5WithName:@"wangwu" password:@"ww" fileName:self.name onComplete:^(NSString *fileURL) {
            if (fileURL == nil)
            {
                completeBlock(NO);
                return;
            }
            self.url = fileURL;
            [self startDownloadToFile:dirPath onDownloading:downloadingBlock onComplete:completeBlock];
        }];
    }else{
        [self startDownloadToFile:dirPath onDownloading:downloadingBlock onComplete:completeBlock];
    }
}

-(void)startDownloadToFile:(NSString *)dirPath onDownloading:(MIBSongDownloadingBlock)downloadingBlock onComplete:(MIBSongDownloadCompleteBlock)completeBlock
{
    __weak SYSong * weakSelf = self;
    
    self.downloading = YES;
    downloadingBlock(0);
    
    NSString *urlStr = [self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString *downloadPath = [[dirPath stringByAppendingPathComponent:self.name] stringByAppendingString:@".mp3.download"];
    
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
            weakSelf.localPath = mp3Path;
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
#pragma mark - property

-(void)setLocalPath:(NSString *)localPath{
    _localPath = localPath;
    
    self.lrcPath = [localPath stringByReplacingOccurrencesOfString:@".mp3" withString:@".lrc"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.lrcPath]) {
        self.lrcPath = @"";
    }
}

-(NSString *)localPath
{
    if (([_localPath hasPrefix:@"/"]) && ![[NSFileManager defaultManager]fileExistsAtPath:_localPath]) {
        _localPath = @"";
    }
    return _localPath;
}

-(float)downloadProgress
{
    [self localPath];
    return _downloadProgress;
}

-(BOOL)isDownloading
{
    [self localPath];
    return _downloading;
}

#warning url获取此处有待完善
-(NSString *)url{
    if (_url == nil) {
        _url = @"";
        __weak typeof (self) weakSelf = self;
        [MIBServer getLogonMD5WithName:@"wangwu" password:@"ww" fileName:self.name onComplete:^(NSString *fileURL) {
            if (fileURL == nil)
            {
                return;
            }
            weakSelf.url = fileURL;
        }];
    }
    return _url;
}

@end
