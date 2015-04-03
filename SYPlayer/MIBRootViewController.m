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

@interface MIBRootViewController ()
- (IBAction)lesson1BtnClick;
- (IBAction)lesson2BtnClick;
- (IBAction)lesson3BtnClick;
- (IBAction)lesson4BtnClick;

@property (nonatomic,strong) NSArray *lessonArray;
@property (nonatomic,assign) int lessonNum;

@end

@implementation MIBRootViewController

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)awakeFromNib
{
//    NSLog(@"awakeFromNib");
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
