//
//  NSDictionary+XYNetworking.m
//  ProjectUkitSet
//
//  Created by xiaoye on 2018/7/5.
//  Copyright © 2018年 ixiye. All rights reserved.
//

#import "NSDictionary+XYNetworking.h"

@implementation NSDictionary (XYNetworking)

- (NSString *)xy_jsonString {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
}


@end
