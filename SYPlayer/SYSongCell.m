//
//  SYSongCell.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-23.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYSongCell.h"
#import "SYSong.h"
#import "Gloable.h"

@interface SYSongCell()
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

@implementation SYSongCell
/** 通过tableView缓存池创建 */
+(instancetype)cellWithTableView:(UITableView *)tableView
{
    NSString *ID = @"playListCell";
    
    SYSongCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSArray *objs = [bundle loadNibNamed:NSStringFromClass(self) owner:nil options:nil];
        
        cell = [objs lastObject];
    }
    
    return cell;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self customInit];
    }
    return self;
}
-(void)customInit{
    self.selectedBackgroundView = [[UIView alloc] init];
    self.backgroundColor = [UIColor clearColor];
    
    self.songNameLabel.textColor = [UIColor whiteColor];
    self.downloadBtn.titleLabel.textColor = [UIColor whiteColor];
    
    [self.playBtn setImage:[UIImage imageNamed:@"miniplayer_btn_playlist_normal"] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"miniplayer_btn_playlist_highlight"] forState:UIControlStateHighlighted];
    [self.playBtn setImage:[UIImage imageNamed:@"miniplayer_btn_playlist_disable"] forState:UIControlStateDisabled];
}
/** Cell被选中 */
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
/** 下载按钮按下 */
- (IBAction)downloadBtnClick {
    if ([self.delegate respondsToSelector:@selector(songCellDownloadBtnClick:)]) {
        [self.delegate songCellDownloadBtnClick:self];
    }
}
/** 播放/暂停按钮点击 */
- (IBAction)playBtnClick {
    self.playing = !self.isPlaying;
}
/** 设定数据并更新Cell */
-(void)setPlayListData:(SYSong *)playListData
{
    _playListData = playListData;
    SYSong *data = self.playListData;
    
//    self.playing = data.playing;
    self.name = data.name;
    self.downloading = data.downloading;
    self.downloadProgress = data.downloadProgress;}
/** Play/Pause */
-(void)setPlaying:(BOOL)playing
{
    _playing = playing;
}
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    UIColor *textColor = selected ? lightGreenColor : [UIColor whiteColor];
    self.songNameLabel.textColor = textColor;
}
/** 设定歌曲名 */
-(void)setName:(NSString *)name
{
    _name = name;
    
    self.songNameLabel.text = self.name;
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
    
    self.playBtn.enabled = NO;//本地不存在的歌曲不能播放
    if (self.isDownloading) {
        if (self.downloadProgress < 1) {
            [self.downloadBtn setTitle:[NSString stringWithFormat:@"%3d%%",(int)(self.downloadProgress * 100)] forState:UIControlStateNormal];
        }
        else
        {
            [self.downloadBtn setTitle:@"已下载" forState:UIControlStateNormal];
            self.downloadBtn.enabled = NO;
            self.playBtn.enabled = YES;//下载完成，可以播放
        }
    }
    else
    {
        [self.downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
    }
}

@end
