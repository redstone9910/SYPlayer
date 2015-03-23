//
//  SYPlayListCell.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-23.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYPlayListCell.h"
#import "SYPlayListModel.h"

@interface SYPlayListCell()
/** 播放按钮 */
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
/** 歌曲名 */
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
/** 下载按钮 */
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
/** 下载按钮按下 */
- (IBAction)downloadBtnClick;
/** 播放/暂停按钮点击 */
- (IBAction)playBtnClick;
@end

@implementation SYPlayListCell
/** 通过tableView缓存池创建 */
+(instancetype)cellWithTableView:(UITableView *)tableView
{
    NSString *ID = @"playListCell";
    
    SYPlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSArray *objs = [bundle loadNibNamed:NSStringFromClass(self) owner:nil options:nil];
        
        cell = [objs lastObject];
    }
    
    return cell;
}
/** 从XIB加载 */
- (void)awakeFromNib {
    // Initialization code
}
/** Cell被选中 */
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
/** 下载按钮按下 */
- (IBAction)downloadBtnClick {
    if ([self.delegate respondsToSelector:@selector(playListCellDownloadBtnClick:)]) {
        [self.delegate playListCellDownloadBtnClick:self];
    }
}
/** 播放/暂停按钮点击 */
- (IBAction)playBtnClick {
    self.playing = !self.isPlaying;
}
/** 设定数据并更新Cell */
-(void)setPlayListData:(SYPlayListModel *)playListData
{
    _playListData = playListData;
    SYPlayListModel *data = self.playListData;
    
    self.playing = data.playing;
    self.songName = data.songName;
    self.downloading = data.downloading;
    self.downloadProgress = data.downloadProgress;}
/** Play/Pause */
-(void)setPlaying:(BOOL)playing
{
    _playing = playing;
    
    UIImage *img = [UIImage imageNamed:(self.isPlaying ? @"btn_play" : @"btn_pause")];
    [self.playBtn setImage:img forState:UIControlStateNormal];
}
/** 设定歌曲名 */
-(void)setSongName:(NSString *)songName
{
    _songName = songName;
    
    self.songNameLabel.text = self.songName;
}
/** 开始下载 */
-(void)setDownloading:(BOOL)downloading
{
    _downloading = downloading;
    
    if (self.isDownloading) self.downloadProgress = 0;
    else [self.downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
}
/** 设定下载进度 */
-(void)setDownloadProgress:(float)downloadProgress
{
    _downloadProgress = downloadProgress;
    
    if (self.isDownloading) {
        if (self.downloadProgress < 1) {
            [self.downloadBtn setTitle:[NSString stringWithFormat:@"%3d%%",(int)(self.downloadProgress * 100)] forState:UIControlStateNormal];
        }
        else
        {
            [self.downloadBtn setTitle:@"已下载" forState:UIControlStateNormal];
        }
    }
    else
    {
        [self.downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
    }
}
@end
