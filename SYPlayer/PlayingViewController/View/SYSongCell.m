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
@property (strong, nonatomic) UIButton *playBtn;
/** 歌曲名 */
@property (strong, nonatomic) UILabel *songNameLabel;
/** 下载按钮 */
@property (strong, nonatomic) UIButton *downloadBtn;
/** 下载按钮按下 */
- (void)downloadBtnClick;
@end

@implementation SYSongCell
/** 通过tableView缓存池创建 */
+(instancetype)cellWithTableView:(UITableView *)tableView
{
    NSString *ID = @"songCell";
    
    SYSongCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[self alloc] init];
    }
    
    return cell;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self customInit];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self customInit];
    }
    return self;
}
-(void)customInit{
//    self.selectedBackgroundView = [[UIView alloc] init];
    self.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.playBtn];
    [self.contentView addSubview:self.songNameLabel];
    [self.contentView addSubview:self.downloadBtn];
    
    self.playBtn.translatesAutoresizingMaskIntoConstraints = NO;
    {
        NSLayoutConstraint *cnsT = [NSLayoutConstraint constraintWithItem:self.playBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *cnsL = [NSLayoutConstraint constraintWithItem:self.playBtn attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint *cnsB = [NSLayoutConstraint constraintWithItem:self.playBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self.contentView addConstraints:@[cnsT,cnsL,cnsB]];
        NSLayoutConstraint *cnsRe = [NSLayoutConstraint constraintWithItem:self.playBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.playBtn attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
        [self.playBtn addConstraints:@[cnsRe]];
    }
    self.songNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    {
        NSLayoutConstraint *cnsY = [NSLayoutConstraint constraintWithItem:self.songNameLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint *cnsL = [NSLayoutConstraint constraintWithItem:self.songNameLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.playBtn attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        NSLayoutConstraint *cnsR = [NSLayoutConstraint constraintWithItem:self.songNameLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.downloadBtn attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        [self.contentView addConstraints:@[cnsY,cnsL,cnsR]];
    }
    self.downloadBtn.translatesAutoresizingMaskIntoConstraints = NO;
    {
        NSLayoutConstraint *cnsT = [NSLayoutConstraint constraintWithItem:self.downloadBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *cnsR = [NSLayoutConstraint constraintWithItem:self.downloadBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        NSLayoutConstraint *cnsB = [NSLayoutConstraint constraintWithItem:self.downloadBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self.contentView addConstraints:@[cnsT,cnsR,cnsB]];
        NSLayoutConstraint *cnsRe = [NSLayoutConstraint constraintWithItem:self.downloadBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.downloadBtn attribute:NSLayoutAttributeHeight multiplier:2 constant:0];
        [self.downloadBtn addConstraints:@[cnsRe]];
    }
}

/** 下载按钮按下 */
- (void)downloadBtnClick {
    if ([self.delegate respondsToSelector:@selector(songCellDownloadBtnClick:)]) {
        [self.delegate songCellDownloadBtnClick:self];
    }
}

#pragma mark - property
/** 设定数据并更新Cell */
-(void)setSong:(SYSong *)song
{
    _song = song;
    SYSong *data = self.song;

    self.songNameLabel.text = data.name;
    
    self.playBtn.enabled = NO;//本地不存在的歌曲不能播放
    
    if (data.downloadProgress < 1) {
        if (data.isDownloading){
            [self.downloadBtn setTitle:[NSString stringWithFormat:@"%3d%%",(int)(data.downloadProgress * 100)] forState:UIControlStateNormal];
            self.downloadBtn.enabled = NO;
        }else{
            if (data.downloadProgress > 0) {
                [self.downloadBtn setTitle:@"继续" forState:UIControlStateNormal];
            }else{
                [self.downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
            }
            self.downloadBtn.enabled = YES;
        }
    }
    else
    {
        [self.downloadBtn setTitle:@"已下载" forState:UIControlStateNormal];
        self.downloadBtn.enabled = NO;
        self.playBtn.enabled = YES;//下载完成，可以播放
    }
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated{
//    [super setSelected:selected animated:animated];
    UIColor *textColor = selected ? lightGreenColor : [UIColor whiteColor];
    self.songNameLabel.textColor = textColor;
}

-(UIButton *)playBtn{
    if (_playBtn == nil) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:@"colorStyle_nowPlaying"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"colorStyle_nowPause"] forState:UIControlStateDisabled];
        _playBtn.hidden = YES;
    }
    return _playBtn;
}
-(UILabel *)songNameLabel{
    if (_songNameLabel == nil) {
        _songNameLabel = [[UILabel alloc] init];
        _songNameLabel.textColor = [UIColor whiteColor];
        _songNameLabel.font = [UIFont systemFontOfSize:15];
    }
    return _songNameLabel;
}
-(UIButton *)downloadBtn{
    if (_downloadBtn == nil) {
        _downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _downloadBtn.titleLabel.textColor = [UIColor whiteColor];
        _downloadBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_downloadBtn addTarget:self action:@selector(downloadBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _downloadBtn.hidden = YES;
    }
    return _downloadBtn;
}
@end
