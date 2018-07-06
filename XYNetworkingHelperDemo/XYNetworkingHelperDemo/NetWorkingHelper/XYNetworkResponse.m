//
//  XYNetworkResponse.m
//  ProjectUkitSet
//
//  Created by xiaoye on 2018/7/5.
//  Copyright © 2018年 ixiye. All rights reserved.
//

#import "XYNetworkResponse.h"
#import <MJExtension.h>
@implementation XYNetworkResponse

MJCodingImplementation

+ (instancetype)responseWithRawData:(id)rawData error:(NSError *)error {
    XYNetworkResponse *response = [[self alloc] init];
    response.rawData = rawData;
    response.error = error;
    
    return response;
}

@end
