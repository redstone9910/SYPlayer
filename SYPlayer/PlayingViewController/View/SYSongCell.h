//
//  SYSongCell.h
//  SYPlayer
//
//  Created by YinYanhui on 15-3-23.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYSong;
@class SYSongCell;

@protocol SYSongCellDelegate <NSObject>
/** 下载按钮点击 */
-(void)songCellDownloadBtnClick:(SYSongCell *)cell;
@end

@interface SYSongCell : UITableViewCell
/** 通过tableView缓存池创建 */
+(instancetype) cellWithTableView:(UITableView *)tableView;
@property (nonatomic,strong) SYSong *playListData;
/** 代理 */
@property (nonatomic,weak) id<SYSongCellDelegate> delegate;

@end
