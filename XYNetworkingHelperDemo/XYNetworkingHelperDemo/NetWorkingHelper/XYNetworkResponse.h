//
//  XYNetworkResponse.h
//  ProjectUkitSet
//
//  Created by xiaoye on 2018/7/5.
//  Copyright © 2018年 ixiye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XYNetworkResponse : NSObject<NSCoding>

/** 原始数据 */
@property (nonatomic, strong) id rawData;

/** 错误 */
@property (nonatomic, strong) NSError *error;

/**
 创建一个响应对象
 
 @param rawData 原始数据
 @param error 错误
 @return 响应对象
 */
+ (instancetype)responseWithRawData:(id)rawData error:(NSError *)error;

@end
