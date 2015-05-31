//
//  SYModel.h
//  SYPlayer
//
//  Created by YinYanhui on 15-5-30.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYModel : NSObject
/** 名 */
@property (nonatomic,copy) NSString *name;
/** 模型转字典 */
-(NSDictionary *)toDict;
/** 通过字典初始化 */
+(instancetype)instanceWithDict:(NSDictionary *)dict;
/** self_id主键 */
@property (nonatomic,assign) long self_id;
/** super_id外键 */
@property (nonatomic,assign) long super_id;
@end
