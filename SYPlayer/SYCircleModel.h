//
//  CircleButtonMoel.h
//  SYPlayer
//
//  Created by YinYanhui on 15-5-7.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYCircleModel : NSObject
/** button下方的标题 */
@property (nonatomic,strong) NSString * bottomTitle;
/** button中央的数字 */
@property (nonatomic,strong) NSString * buttonTitle;

+(instancetype)circleMoelWithDict:(NSDictionary *)dict;
-(instancetype)initModelWithDict:(NSDictionary *)dict;

@end
