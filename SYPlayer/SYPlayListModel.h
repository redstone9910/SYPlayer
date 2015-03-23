//
//  SYPlayListModel.h
//  SYPlayer
//
//  Created by YinYanhui on 15-3-23.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYPlayListModel : NSObject
/** 正在播放/暂停 */
@property (nonatomic,assign,getter = isPlaying) BOOL playing;
/** 歌曲名 */
@property (nonatomic,copy) NSString * songName;
/** 下载进度:0.0~1.0 */
@property (nonatomic,assign) float downloadProgress;
/** 是否下载中 */
@property (nonatomic,assign,getter=isDownloading) BOOL downloading;
/** 本地文件路径 */
@property (nonatomic,copy) NSString * mp3URL;

-(instancetype) initWithDict:(NSDictionary *)dict;
+(instancetype) playListModelWithDict:(NSDictionary*)dict;
@end
