//
//  SYSongCell.h
//  SYPlayer
//
//  Created by YinYanhui on 15-3-23.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYSongModel;
@class SYSongCell;

@protocol SYSongCellDelegate <NSObject>
/** 下载按钮点击 */
-(void)songCellDownloadBtnClick:(SYSongCell *)cell;
@end

@interface SYSongCell : UITableViewCell
/** 通过tableView缓存池创建 */
+(instancetype) cellWithTableView:(UITableView *)tableView;
@property (nonatomic,strong) SYSongModel *playListData;
/** 正在播放/暂停 */
@property (nonatomic,assign,getter = isPlaying) BOOL playing;
/** 歌曲名 */
@property (nonatomic,copy) NSString * songName;
/** 下载进度:0.0~1.0 */
@property (nonatomic,assign) float downloadProgress;
/** 是否下载中 */
@property (nonatomic,assign,getter=isDownloading) BOOL downloading;
/** 代理 */
@property (nonatomic,weak) id<SYSongCellDelegate> delegate;

@end
