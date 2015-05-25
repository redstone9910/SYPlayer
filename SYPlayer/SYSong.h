//
//  SYSong.h
//  SYPlayer
//
//  Created by YinYanhui on 15-3-23.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^MIBSongDownloadCompleteBlock)(BOOL complete);
typedef void(^MIBSongDownloadingBlock)(float progress);

@interface SYSong : NSObject
/** 歌曲名 */
@property (nonatomic,copy) NSString *name;
/** 下载进度:0.0~1.0 */
@property (nonatomic,assign) float downloadProgress;
/** 是否下载中 */
@property (nonatomic,assign,getter=isDownloading) BOOL downloading;
/** 本地文件路径 */
@property (nonatomic,copy) NSString *localPath;
/** URL */
@property (nonatomic,copy) NSString *url;

/** 查找MP3文件并创建对象 */
+(SYSong *)songWithFileName:(NSString *)name inDir:(NSString *)dir;
/** 通过字典初始化 */
+(instancetype) songModelWithDict:(NSDictionary*)dict;
/** 模型转字典 */
-(NSDictionary *)toDict;
/** 检查本地文件路径是否有更新 YES:有更新 NO:无更新 */
-(BOOL)updeteCheckInDir:(NSString *)dir;

/** 准备开始下载 */
-(void)prepareDownloadToFile:(NSString *)dirPath onDownloading:(MIBSongDownloadingBlock)downloadingBlock onComplete:(MIBSongDownloadCompleteBlock)completeBlock;
@end
