//
//  MIBRootViewController.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-20.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "MIBRootViewController.h"
#import "SYPlayingViewController.h"
#import "SYPlayListModel.h"
#import "MobClick.h"
#import "SYCircleCell.h"
#import "SYCircleModel.h"

#define SYCircleCellID @"SYCircleCell"

@interface MIBRootViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,SYCircleCellDelegate>
- (IBAction)lesson1BtnClick;
- (IBAction)lesson2BtnClick;
- (IBAction)lesson3BtnClick;
- (IBAction)lesson4BtnClick;
/** 按钮容器 */
@property (nonatomic,strong) UICollectionView * buttonContainer;

@property (nonatomic,strong) NSArray *lessonArray;
@property (nonatomic,assign) int lessonNum;
@property (nonatomic,strong) UICollectionView *volumePage;

@end

@implementation MIBRootViewController
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
    // 1.流水布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    // 2.每个cell的尺寸
    layout.itemSize = CGSizeMake(60, 90);
    // 3.设置cell之间的水平间距
    layout.minimumInteritemSpacing = 50;
    // 4.设置cell之间的垂直间距
    layout.minimumLineSpacing = 20;
    // 5.设置四周的内边距
    layout.sectionInset = UIEdgeInsetsMake(20, 50, 0, 50);
    self.volumePage = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [self.volumePage registerClass:[SYCircleCell class] forCellWithReuseIdentifier:SYCircleCellID];
    self.volumePage.delegate = self;
    self.volumePage.dataSource = self;
    self.volumePage.backgroundColor = [UIColor clearColor];
    
    /** volumePage约束 */
    [self.view addSubview:self.volumePage];
    self.volumePage.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *cnsT2 = [NSLayoutConstraint constraintWithItem:self.volumePage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backBg attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *cnsB2 = [NSLayoutConstraint constraintWithItem:self.volumePage attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-50];
    NSLayoutConstraint *cnsL2 = [NSLayoutConstraint constraintWithItem:self.volumePage attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *cnsR2 = [NSLayoutConstraint constraintWithItem:self.volumePage attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    [self.view addConstraints:@[cnsT2,cnsB2,cnsL2,cnsR2]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"nec_mp3_file_list" ofType:@"txt"];
    NSString *plistFilePath = [SYPlayListModel playListArrayFileWithMp3FileList:fileName withPlistFileName:@"root.plist"];
    
    if(plistFilePath != nil)
    {
        NSMutableArray *lessonArray = [NSMutableArray array];
        NSArray *fileArray = [NSArray arrayWithContentsOfFile:plistFilePath];
        for (NSDictionary *dict in fileArray) {
            SYPlayListModel *model = [SYPlayListModel playListWithDict:dict];
            [lessonArray addObject:model];
        }
        
        self.lessonArray = lessonArray;
    }
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
    
    return cell;
}

#pragma - mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SYCircleModel *p = self.circles[indexPath.item];
    NSLog(@"点击了---%@", p.bottomTitle);
}
#pragma mark - SYCircleCellDelegate
-(void)circleCellDidClick:(SYCircleCell *)cell{
    NSIndexPath *indexPath = [self.volumePage indexPathForCell:cell];
    SYCircleModel *p = self.circles[indexPath.item];
    NSLog(@"点击按钮-%@", p.bottomTitle);
}
#pragma mark - property
-(NSArray *)circles{
    if (_circles == nil) {
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VolumeList.plist" ofType:nil]];
        NSMutableArray *circleArray = [NSMutableArray array];
        for (NSDictionary *dict in dictArray) {
            SYCircleModel *model = [SYCircleModel circleMoelWithDict:dict];
            [circleArray addObject:model];
        }
        _circles = [circleArray copy];
    }
    return _circles;
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    id vc = segue.destinationViewController;
    
    if([vc isKindOfClass:[SYPlayingViewController class]])
    {
        SYPlayingViewController *sVc = (SYPlayingViewController *)vc;
        SYPlayListModel *model = self.lessonArray[self.lessonNum - 1];
        sVc.playListModel = model;
    }
}

- (IBAction)lesson1BtnClick {
    self.lessonNum = 1;
    [self performSegueWithIdentifier:@"main2playing" sender:self];
}

- (IBAction)lesson2BtnClick {
    self.lessonNum = 2;
    [self performSegueWithIdentifier:@"main2playing" sender:self];
}

- (IBAction)lesson3BtnClick {
    self.lessonNum = 3;
    [self performSegueWithIdentifier:@"main2playing" sender:self];
}

- (IBAction)lesson4BtnClick {
    self.lessonNum = 4;
    [self performSegueWithIdentifier:@"main2playing" sender:self];
}

@end
