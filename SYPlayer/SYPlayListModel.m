//
//  SYPlayListModel.m
//  SYPlayer
//
//  Created by YinYanhui on 15-3-23.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYPlayListModel.h"

@implementation SYPlayListModel
/** 通过字典创建 */
+(instancetype)playListModelWithDict:(NSDictionary *)dict
{
    return [[self alloc]initWithDict:dict];
}
/** 通过字典初始化 */
-(instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
@end
