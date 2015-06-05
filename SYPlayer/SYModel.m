//
//  SYModel.m
//  SYPlayer
//
//  Created by YinYanhui on 15-5-30.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYModel.h"
#import "MJExtension.h"

@implementation SYModel
/** 从字典创建对象 */
+(instancetype)instanceWithDict:(NSDictionary *)dict{
    return [self objectWithKeyValues:dict];
}
/** model转dic */
-(NSDictionary *)toDict
{
    return [self keyValues];
}
-(instancetype)init{
    if (self = [super init]) {
        self.name = [NSString string];
    }
    return self;
}

@end
