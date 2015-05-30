//
//  SYSong.h
//  SYPlayer
//
//  Created by YinYanhui on 15-3-23.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYModel.h"

@interface SYSong : SYModel
/** 下载进度:0.0~1.0 */
@property (nonatomic,assign) float downloadProgress;
/** 是否下载中 */
@property (nonatomic,assign,getter=isDownloading) BOOL downloading;
/** 本地文件路径 */
@property (nonatomic,copy) NSString *localPath;
/** URL */
@property (nonatomic,copy) NSString *url;
/** LRC文件路径 */
@property (nonatomic,copy) NSString *lrcPath;

/** 查找MP3文件并创建对象 */
+(SYSong *)songWithFileName:(NSString *)name inDir:(NSString *)dir;
/** 通过字典初始化 */
+(instancetype) songModelWithDict:(NSDictionary*)dict;
/** 检查本地文件路径是否有更新 YES:有更新 NO:无更新 */
-(BOOL)updeteCheckInDir:(NSString *)dir;

/** 准备开始下载 */
-(void)prepareDownloadToFile:(NSString *)dirPath onDownloading:(void(^)(float progress))downloadingBlock onComplete:(void(^)(BOOL success))completeBlock;
/** 获取URL */
-(void)fetchURL:(void(^)(BOOL success))completeBlock;
/** 获取LRC */
-(void)fetchLRCToDir:(NSString *)dir complete:(void(^)(BOOL success))completeBlock;
@end
