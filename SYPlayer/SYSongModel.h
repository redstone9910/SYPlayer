//
//  SYSongModel.h
//  SYPlayer
//
//  Created by YinYanhui on 15-3-23.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^MIBSongDownloadCompleteBlock)(BOOL complete);
typedef void(^MIBSongDownloadingBlock)(float progress);

@interface SYSongModel : NSObject
/** 正在播放/暂停 */
@property (nonatomic,assign,getter = isPlaying) BOOL playing;
/** 歌曲名 */
@property (nonatomic,copy) NSString *songName;
/** 下载进度:0.0~1.0 */
@property (nonatomic,assign) float downloadProgress;
/** 是否下载中 */
@property (nonatomic,assign,getter=isDownloading) BOOL downloading;
/** 本地文件路径 */
@property (nonatomic,copy) NSString *mp3URL;
/** 通过字典创建 */
-(instancetype) initWithDict:(NSDictionary *)dict;
/** 通过字典初始化 */
+(instancetype) songModelWithDict:(NSDictionary*)dict;
/** 准备开始下载 */
-(void)prepareDownload:(MIBSongDownloadingBlock)downloadingBlock onComplete:(MIBSongDownloadCompleteBlock)completeBlock;
/** 通过歌曲名数组创建Plist文件 */
+(NSString *) songModelArrayWithFileNameArray:(NSArray *)nameArray withPlistFileName:(NSString *)plist atPath:(NSString *)rootPath;
@end
