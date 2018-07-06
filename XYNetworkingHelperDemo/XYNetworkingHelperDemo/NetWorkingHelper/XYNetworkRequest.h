//
//  XYNetworkRequest.h
//  ProjectUkitSet
//
//  Created by xiaoye on 2018/7/5.
//  Copyright © 2018年 ixiye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYNetworkingEnum.h"

@interface XYNetworkRequest : NSObject

/** 请求地址 */
@property (nonatomic, copy) NSString *urlStr;

/** 请求方法 */
@property (nonatomic, assign) XYNetworkingRequestMethod requestMethod;

/** 请求参数 */
@property (nonatomic, strong) NSDictionary *params;

/** 请求头 */
@property (nonatomic, strong) NSDictionary *header;

/** 缓存方式 */
@property (nonatomic, assign) XYNetworkingCachePolicy cachePolicy;

/** 请求序列化格式 */
@property (nonatomic, assign) XYNetRequestSerializer requestSerializer;

/** 请求超时时间 */
@property (nonatomic, assign) NSTimeInterval requestTimeoutInterval;

+ (instancetype)requestWithUrlStr:(NSString *)urlStr method:(XYNetworkingRequestMethod)method cachePolicy:(XYNetworkingCachePolicy)cachePolicy params:(NSDictionary *)params;

@end
