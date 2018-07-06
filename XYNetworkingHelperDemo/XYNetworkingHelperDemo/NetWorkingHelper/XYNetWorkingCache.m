//
//  XYNetWorkingCache.m
//  ProjectUkitSet
//
//  Created by xiaoye on 2018/7/6.
//  Copyright © 2018年 ixiye. All rights reserved.
//

#import "XYNetWorkingCache.h"
#import <CommonCrypto/CommonDigest.h>

@implementation XYNetWorkingCache

static NSString * const NetWorkingResponseCache = @"NetworkResponseCache";
static YYCache * _dataCache;

+ (void)initialize {
    
    _dataCache = [YYCache cacheWithName:NetWorkingResponseCache];
}

//缓存网络数据
+(void)setHttpCache:(id)httpData URL:(NSString *)URL parameters:(NSDictionary *)parameters {
    NSString * cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
    //异步缓存，不会阻塞主线程
    [_dataCache setObject:httpData forKey:cacheKey withBlock:nil];
}

//取出数据
+ (id)httpCacheForURL:(NSString *)URL parameters:(NSDictionary *)parameters {
    NSString * cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
    return [_dataCache objectForKey:cacheKey];
}

//异步取出缓存数据
+ (void)cacheForURL:(NSString *)URL parameters:(NSDictionary *)parameters withBlock:(void (^)(id<NSCoding>))block {
    NSString * cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
    [_dataCache objectForKey:cacheKey withBlock:^(NSString * _Nonnull key, id<NSCoding>  _Nonnull object) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(object);
        });
    }];
}

//获取缓存大小
+ (NSString *)getAllHttpCacheSize {
    
    //获取网络缓存的总大小 bytes(字节)
    NSInteger cacheSize = [_dataCache.diskCache totalCost];
    if (cacheSize < 1024) {
        return [NSString stringWithFormat:@"%ldB",(long)cacheSize];
    } else if (cacheSize < powf(1024.f, 2)) {
        return [NSString stringWithFormat:@"%.2fKB",cacheSize / 1024.f];
    } else if (cacheSize < powf(1024.f, 3)) {
        return [NSString stringWithFormat:@"%.2fMB",cacheSize / powf(1024.f, 2)];
    } else {
        return [NSString stringWithFormat:@"%.2fGB",cacheSize / powf(1024.f, 3)];
    }
}

+ (void)removeAllHttpCache {
    [_dataCache.diskCache removeAllObjects];
}

+ (void)removeAllHttpCacheBlock:(void(^)(int removedCount, int totalCount))progress
                       endBlock:(void(^)(BOOL error))end {
    
    [_dataCache.diskCache removeAllObjectsWithProgressBlock:progress endBlock:end];
    
}

//得到缓存，取出的key值
+ (NSString *)cacheKeyWithURL:(NSString *)URL parameters:(NSDictionary *)parameters {
    if (!parameters) {
        return URL;
    } else {
        //将参数字典转换成字符串
        NSData * stringData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
        NSString * paraString = [[NSString alloc]initWithData:stringData encoding:NSUTF8StringEncoding];
        
        //将URL与转换好的参数字符串拼接在一起，成为最终存储的KEY值
        NSString * cacheKey = [NSString stringWithFormat:@"%@%@",URL,paraString];
        
        return [self dk_md5:cacheKey];
    }
}

/**
 MD5加密
 
 @param input 待加密字符串
 @return MD5加密后的字符串
 */
+ (NSString *)dk_md5:(NSString *)input {
    const char *cStr = [[input dataUsingEncoding:NSUTF8StringEncoding] bytes];
    unsigned char digest[16];
    CC_MD5(cStr, (uint32_t)[[input dataUsingEncoding:NSUTF8StringEncoding] length], digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

@end
