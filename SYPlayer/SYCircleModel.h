//
//  CircleButtonMoel.h
//  SYPlayer
//
//  Created by YinYanhui on 15-5-7.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYCircleModel : NSObject
/** 第x册 */
@property (nonatomic,copy) NSString * name;
/** 册编号 */
@property (nonatomic,assign) long aindex;

+(instancetype)circleMoelWithDict:(NSDictionary *)dict;
-(instancetype)initModelWithDict:(NSDictionary *)dict;

@end
