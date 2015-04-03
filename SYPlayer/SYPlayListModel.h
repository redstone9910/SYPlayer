//
//  SYPlayListModel.h
//  SYPlayer
//
//  Created by YinYanhui on 15-4-2.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYPlayListModel : NSObject
/** 第x册 */
@property (nonatomic,copy) NSString * lessonTitle;
/** SYSongListModel Dict Array */
@property (nonatomic,strong) NSArray * songList;
/** 通过字典创建 */
+(instancetype)playListWithDict:(NSDictionary *)dict;
/** 通过文件列表创建列表Plist文件 */
+(NSString *)playListArrayFileWithMp3FileList:(NSString *)file withPlistFileName:(NSString *)plist;
/** 通过字典初始化 */
-(instancetype)initWithDict:(NSDictionary *)dict;
@end
