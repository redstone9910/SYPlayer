//
//  CircleButtonMoel.m
//  SYPlayer
//
//  Created by YinYanhui on 15-5-7.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYCircleModel.h"

@implementation SYCircleModel
+(instancetype)circleMoelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initModelWithDict:dict];
}
-(instancetype)initModelWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.bottomTitle = dict[@"bottomTitle"];
        self.buttonTitle = dict[@"buttonTitle"];
//        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
@end
