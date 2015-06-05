//
//  SYMediaInfo.m
//  SYPlayer
//
//  Created by YinYanhui on 15-5-26.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYMediaInfo.h"
#import "MJExtension.h"

@implementation SYMediaInfo
/** 通过字典创建 */
+(instancetype)songModelWithDict:(NSDictionary *)dict
{
    return [self objectWithKeyValues:dict];
}
/** 通过字典初始化 */
-(instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
/** model转dic */
-(NSDictionary *)toDict
{
    return [self keyValues];
}
@end
