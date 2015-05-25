//
//  SYRootViewController.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-20.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYRootViewController.h"
#import "SYPlayingViewController.h"
#import "SYPlaylist.h"
#import "MobClick.h"
#import "SYCircleCell.h"
#import "SYCircleModel.h"
#import "SYCollectionViewLayout.h"
#import "SYPlaylists.h"
#import "SYAudioController.h"
#import "Gloable.h"

#define SYCircleCellID @"SYCircleCell"

@interface SYRootViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,SYCircleCellDelegate>
/** 按钮容器 */
@property (nonatomic,strong) UICollectionView *volumePage;
/** 按钮面板数据 */
@property (nonatomic,strong) NSArray *circles;

@end

@implementation SYRootViewController
-(void)loadView{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    /** backBg初始化 */
    self.backBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_bg"]];
    /** backBg约束 */
    [self.view addSubview:self.backBg];
    self.backBg.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *cnsT1 = [NSLayoutConstraint constraintWithItem:self.backBg attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *cnsL1 = [NSLayoutConstraint constraintWithItem:self.backBg attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *cnsR1 = [NSLayoutConstraint constraintWithItem:self.backBg attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    [self.view addConstraints:@[cnsT1,cnsL1,cnsR1]];
    
    NSLayoutConstraint *cnsRe1 = [NSLayoutConstraint constraintWithItem:self.backBg attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.backBg attribute:NSLayoutAttributeHeight multiplier:(144.0 / 149.0) constant:0];
    [self.backBg addConstraints:@[cnsRe1]];
    
    /** volumePage初始化 */
    SYCollectionViewLayout *layout = [[SYCollectionViewLayout alloc] init];
    self.volumePage = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [self.volumePage registerClass:[SYCircleCell class] forCellWithReuseIdentifier:SYCircleCellID];
    self.volumePage.delegate = self;
    self.volumePage.dataSource = self;
    self.volumePage.backgroundColor = [UIColor clearColor];
    
    /** volumePage约束 */
    [self.view addSubview:self.volumePage];
    self.volumePage.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *cnsT = [NSLayoutConstraint constraintWithItem:self.volumePage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backBg attribute:NSLayoutAttributeBottom multiplier:1 constant:10];
    NSLayoutConstraint *cnsB = [NSLayoutConstraint constraintWithItem:self.volumePage attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-50];
    NSLayoutConstraint *cnsL = [NSLayoutConstraint constraintWithItem:self.volumePage attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *cnsR = [NSLayoutConstraint constraintWithItem:self.volumePage attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    [self.view addConstraints:@[cnsT,cnsB,cnsL,cnsR]];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [[SYAudioController sharedAudioController] play];
}

-(void)dealloc{
    [self.volumes save];
    SYLog(@"%@ dealloc",NSStringFromClass([self class]));
}
#pragma - mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.circles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 1.获得cell
    SYCircleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SYCircleCellID forIndexPath:indexPath];
    
    // 2.传递模型
    cell.model = self.circles[indexPath.item];
    cell.delegate = self;
    cell.defaultColor = [UIColor blackColor];
    
    return cell;
}

#pragma - mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SYCircleModel *p = self.circles[indexPath.item];
    NSLog(@"点击了---%@", p.volumeTitle);
}
#pragma mark - SYCircleCellDelegate
-(void)circleCellDidClick:(SYCircleCell *)cell{
    NSIndexPath *indexPath = [self.volumePage indexPathForCell:cell];
    SYCircleModel *p = self.circles[indexPath.item];
    
    SYPlayingViewController *sVc = [[SYPlayingViewController alloc] init];
    self.volumes.playingIndex = p.volumeIndex - 1;
    [self.volumes save];
    
    [self presentViewController:sVc animated:YES completion:^{
    }];
}
#pragma mark - property
-(NSArray *)circles{
    if (_circles == nil) {
        NSArray *playListArray = self.volumes.playLists;
        NSMutableArray *circleArray = [NSMutableArray array];
        for (SYPlaylist *list in playListArray) {
            SYCircleModel *model = [SYCircleModel circleMoelWithDict:[list toDict]];
            [circleArray addObject:model];
        }
        _circles = [circleArray copy];
    }
    return _circles;
}

-(SYPlaylists *)volumes{
    if (_volumes == nil) {
        _volumes = [SYAudioController sharedAudioController].volumes;
    }
    return _volumes;
}
@end
