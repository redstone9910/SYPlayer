//
//  SYPlayListTableView.m
//  SYPlayer
//
//  Created by YinYanhui on 15-5-25.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYPlayListTableView.h"
#import "FXBlurView.h"
#import "Gloable.h"

@interface SYPlayListTableView()
@property (nonatomic,strong) NSIndexPath * prevIndexPath;
@property (nonatomic,strong) NSIndexPath * selectedIndexPath;
@end

@implementation SYPlayListTableView

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
    self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
}

-(void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition{
    [super selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
    self.selectedIndexPath = indexPath;
}

-(void)setSelectedRow:(long)selectedRow{
    [self setSelectedIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:self.selectedIndexPath.section]];
}

-(void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath{
    self.prevIndexPath = _selectedIndexPath;
    UITableViewCell *prevCell = [self cellForRowAtIndexPath:self.prevIndexPath];
    [prevCell setSelected:NO];
    
    _selectedIndexPath = selectedIndexPath;
    _selectedRow = selectedIndexPath.row;
    UITableViewCell *currCell = [self cellForRowAtIndexPath:_selectedIndexPath];
    [currCell setSelected:YES];
}

#pragma mark - property
@end
