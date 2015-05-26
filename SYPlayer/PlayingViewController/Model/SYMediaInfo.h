//
//  SYMediaInfo.h
//  SYPlayer
//
//  Created by YinYanhui on 15-5-26.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYMediaInfo : NSObject
/** StreamInfos */
@property (nonatomic,copy) NSString * Artist;
@property (nonatomic,copy) NSString * Title;
/** 通过字典创建 */
+(instancetype)songModelWithDict:(NSDictionary *)dict;
/** 通过字典初始化 */
-(instancetype)initWithDict:(NSDictionary *)dict;
/** model转dic */
-(NSDictionary *)toDict;
@end
