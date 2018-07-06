//
//  XYNetWorkingCache.h
//  ProjectUkitSet
//
//  Created by xiaoye on 2018/7/6.
//  Copyright © 2018年 ixiye. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <YYCache.h>
// 过期提醒
#define Deprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

#define XYNetworkCache(URL,Parameters) [XYNetWorkingCache httpCacheForURL:URL parameters:Parameters]


@interface XYNetWorkingCache : NSObject

#pragma mark - 网络数据缓存类

/**
 *  缓存网络数据,根据请求的 URL与parameters
 *  做KEY存储数据, 这样就能缓存多级页面的数据
 *
 *  @param httpData   服务器返回的数据
 *  @param URL        请求的URL地址
 *  @param parameters 请求的参数
 */
+ (void)setHttpCache:(id)httpData URL:(NSString *)URL parameters:(NSDictionary *)parameters;

/**
 *  根据请求的 URL与parameters 取出缓存数据
 *
 *  @param URL        请求的URL
 *  @param parameters 请求的参数
 *
 *  @return 缓存的服务器数据
 */
+ (id)httpCacheForURL:(NSString *)URL parameters:(NSDictionary *)parameters;

/**
 *  根据请求的URL与parameters 异步取出缓存数据
 *
 *  @param URL 请求的URL
 *  @param parameters 请求的参数
 *  @param block 异步回调缓存的数据
 */
+ (void)cacheForURL:(NSString *)URL parameters:(NSDictionary *)parameters withBlock:(void(^)(id<NSCoding> object))block;


/**
 *  获取网络缓存的总大小 动态单位(GB,MB,KB,B)
 *
 *  @return 网络缓存的总大小
 */
+ (NSString *)getAllHttpCacheSize;

/**
 *  删除所有网络缓存,
 */
+ (void)removeAllHttpCache;

/**
 *  删除所有网络缓存
 *  推荐使用该方法 不会阻塞主线程，同时返回Progress
 */
+ (void)removeAllHttpCacheBlock:(void(^)(int removedCount, int totalCount))progress
                       endBlock:(void(^)(BOOL error))end;

@end
