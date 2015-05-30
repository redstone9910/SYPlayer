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

@interface SYSong ()
/** 开始下载 */
//@property (strong, nonatomic) MKNetworkOperation *downloadOperation;
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
    return [self instanceWithDict:dict];
}
-(instancetype)init{
    if (self = [super init]) {
        self.localPath = [NSString string];
        self.url = [NSString string];
        self.lrcPath = [NSString string];
    }
    return self;
}

/** 检查本地文件路径是否有更新 YES:有更新 NO:无更新 */
-(BOOL)updeteCheckInDir:(NSString *)dir{
    BOOL ret = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.localPath]){
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
            ret = YES;
        }
    }
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.lrcPath]){
        /** 文件不存在，按照dir目录查找 */
        NSString *name = [self.name stringByAppendingString:@".lrc"];
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *sPath = [[[bundle resourcePath] stringByAppendingPathComponent:dir] stringByAppendingPathComponent:name];//查找resource目录
        if(![[NSFileManager defaultManager]fileExistsAtPath:sPath]){
            sPath = [[catchePath stringByAppendingPathComponent:dir] stringByAppendingPathComponent:name];//查找沙盒目录
            if(![[NSFileManager defaultManager] fileExistsAtPath:sPath])
            {
                sPath = @"";
            }
        }
        
        if(![self.lrcPath isEqualToString:sPath]){
            self.lrcPath = sPath;
            ret = YES;
        }
    }
    
    return ret;
}

-(void)prepareDownloadToFile:(NSString *)dirPath onDownloading:(void(^)(float progress))downloadingBlock onComplete:(void(^)(BOOL success))completeBlock
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

-(void)startDownloadToFile:(NSString *)dirPath onDownloading:(void(^)(float progress))downloadingBlock onComplete:(void(^)(BOOL success))completeBlock
{
    __weak SYSong * weakSelf = self;
    
    self.downloading = YES;
    downloadingBlock(0);
    
    NSString *urlStr = [self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString *downloadPath = [[dirPath stringByAppendingPathComponent:self.name] stringByAppendingString:@".mp3.download"];
    
    MKNetworkOperation *downloadOperation = [[MKDownloader sharedDownloader] downloadFatAssFileFrom:urlStr toFile:downloadPath];
    [downloadOperation onDownloadProgressChanged:^(double progress) {
        self.downloadProgress = progress;
        downloadingBlock(progress);
    }];
    
    [downloadOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
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
            MKNetworkOperation *downloadOperation = [[MKDownloader sharedDownloader] downloadFatAssFileFrom:lrcURL toFile:lrcPath];
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

/** 获取URL */
-(void)fetchURL:(void(^)(BOOL success))completeBlock{
    __weak typeof (self) weakSelf = self;
    [MIBServer fetchURLWithFileName:self.name onComplete:^(NSString *fileURL) {
        weakSelf.url = fileURL;
        completeBlock(fileURL != nil);
    }];
}

/** 获取LRC */
-(void)fetchLRCToDir:(NSString *)dir complete:(void(^)(BOOL success))completeBlock{
    static MKNetworkOperation *downloadOperation;
    
    //下载LRC文件
    NSString *lrcURL = [[self.url stringByReplacingOccurrencesOfString:@".mp3" withString:@".lrc"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *lrcRoot = [catchePath stringByAppendingPathComponent:dir];
    if (![[NSFileManager defaultManager] fileExistsAtPath:lrcRoot]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:lrcRoot withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString *lrcPath = [[lrcRoot stringByAppendingPathComponent:self.name] stringByAppendingString:@".lrc.download"];
    
    downloadOperation = [[MKDownloader sharedDownloader] downloadFatAssFileFrom:lrcURL toFile:lrcPath];
    
    __weak typeof(self) wealSelf = self;
    [downloadOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        //重命名文件
        wealSelf.lrcPath = [lrcPath stringByReplacingOccurrencesOfString:@".lrc.download" withString:@".lrc"];
        [[NSFileManager defaultManager] copyItemAtPath:lrcPath toPath:wealSelf.lrcPath error:nil];
        if ([[NSFileManager defaultManager] fileExistsAtPath:wealSelf.lrcPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:lrcPath error:nil];
            completeBlock(YES);
        }else{
            self.lrcPath = nil;
            completeBlock(NO);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        wealSelf.lrcPath = nil;
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

-(NSString *)url{
    if (_url == nil) {
        _url = @"";
    }
    return _url;
}
@end
