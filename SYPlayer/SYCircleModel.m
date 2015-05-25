//
//  CircleButtonMoel.m
//  SYPlayer
//
//  Created by YinYanhui on 15-5-7.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYCircleModel.h"
#import "MJExtension.h"

@implementation SYCircleModel
+(instancetype)circleMoelWithDict:(NSDictionary *)dict
{
    return[self objectWithKeyValues:dict];
}
-(instancetype)initModelWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        [self setKeyValues:dict];
    }
    return self;
}
@end
