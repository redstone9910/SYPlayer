//
//  MIBRootViewController.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-20.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "MIBRootViewController.h"
#import "SYPlayingViewController.h"

@interface MIBRootViewController ()
- (IBAction)lesson1BtnClick;
- (IBAction)lesson2BtnClick;
- (IBAction)lesson3BtnClick;
- (IBAction)lesson4BtnClick;
@end

@implementation MIBRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.navigationController.view.backgroundColor = [UIColor clearColor];
//    self.navigationController.view.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
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
        sVc.title = self.title;
    }
}


- (IBAction)lesson1BtnClick {
    self.title = @"第一册";
    [self performSegueWithIdentifier:@"main2playing" sender:self];
}

- (IBAction)lesson2BtnClick {
    self.title = @"第二册";
    [self performSegueWithIdentifier:@"main2playing" sender:self];
}

- (IBAction)lesson3BtnClick {
    self.title = @"第三册";
    [self performSegueWithIdentifier:@"main2playing" sender:self];
}

- (IBAction)lesson4BtnClick {
    self.title = @"第四册";
    [self performSegueWithIdentifier:@"main2playing" sender:self];
}

@end
