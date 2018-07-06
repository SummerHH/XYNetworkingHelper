//
//  XYNetworkRequest.m
//  ProjectUkitSet
//
//  Created by xiaoye on 2018/7/5.
//  Copyright © 2018年 ixiye. All rights reserved.
//

#import "XYNetworkRequest.h"

@implementation XYNetworkRequest

+ (instancetype)requestWithUrlStr:(NSString *)urlStr method:(XYNetworkingRequestMethod)method cachePolicy:(XYNetworkingCachePolicy)cachePolicy params:(NSDictionary *)params {
    
    XYNetworkRequest *request = [[self alloc] init];
    request.urlStr = urlStr;
    request.requestMethod = method;
    request.params = params;
    request.cachePolicy = cachePolicy;
    
    return request;
}

@end
