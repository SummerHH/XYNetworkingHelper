# XYNetworjingHelper
给予AFNetworking 和 YYCache 封装带缓存的网络请求库,对请求结果可自行处理

![image](https://raw.githubusercontent.com/SummerHH/XYNetworkingHelper/master/networkImg/IMG_0171.PNG) 

```

/**缓存方式 */
typedef NS_ENUM(NSUInteger, XYNetworkingCachePolicy){
/**只从网络获取数据，且数据不会缓存在本地*/
XYNetworkingCachePolicyIgnoreCache = 0,
/**只从缓存读数据，如果缓存没有数据，返回一个空*/
XYNetworkingCachePolicyCacheOnly = 1,
/**先从网络获取数据，同时会在本地缓存数据*/
XYNetworkingCachePolicyNetworkOnly = 2,
/**先从缓存读取数据，如果没有再从网络获取*/
XYNetworkingCachePolicyCacheElseNetwork = 3,
/**先从网络获取数据，如果没有在从缓存获取，此处的没有可以理解为访问网络失败，再从缓存读取*/
XYNetworkingCachePolicyNetworkElseCache = 4,
/**先从缓存读取数据，然后在从网络获取并且缓存，在这种情况下，Block将产生两次调用*/
XYNetworkingCachePolicyCacheThenNetwork = 5
};

/**网络状态 */
typedef NS_ENUM(NSUInteger,XYNetworkingStatusType) {
/**未知网络 */
XYNetworkingStatusUnKnown,
/**无网络 */
XYNetworkingStatusNotReachable,
/**手机网络 */
XYNetworkingStatusReachableViaWWAN,
/**WIFI网络 */
XYNetworkingStatusReachableViaWiFi
};

/**设置请求参数*/
typedef NS_ENUM(NSUInteger, XYNetRequestSerializer) {
/** 响应数据为JSON格式*/
XYNetRequestSerializerJSON,
/** 响应数据为二进制格式*/
XYNetRequestSerializerHTTP
};

/**设置响应数据 */
typedef NS_ENUM(NSUInteger,XYNetResponseSerializer) {
/** JSON格式*/
XYNetResponseSerializerJSON,
/** 二进制格式*/
XYNetResponseSerializerHTTP
};

/**请求方式*/
typedef NS_ENUM(NSUInteger, XYNetworkingRequestMethod){
/**GET请求方式*/
XYNetworkingRequestMethodGET = 0,
/**POST请求方式*/
XYNetworkingRequestMethodPOST,
/**HEAD请求方式*/
XYNetworkingRequestMethodHEAD,
/**PUT请求方式*/
XYNetworkingRequestMethodPUT,
/**PATCH请求方式*/
XYNetworkingRequestMethodPATCH,
/**DELETE请求方式*/
XYNetworkingRequestMethodDELETE
};



/**
发起一个请求

@param request 请求对象
@param callback 请求响应回调
@return 返回的对象可取消请求,调用cancel方法
*/
+ (__kindof NSURLSessionTask *)request:(XYNetworkRequest *)request callback:(XYHttpRequestBlock)callback;


/**
*  GET请求,无缓存
*
*  @param URL        请求地址
*  @param parameters 请求参数
*  @param callback   请求的回调
*
*  @return 返回的对象可取消请求,调用cancel方法
*/
+ (__kindof NSURLSessionTask *)GET:(NSString *)URL
parameters:(NSDictionary *)parameters
callback:(XYHttpRequestBlock)callback;


/**
*  GET请求,自动缓存
*
*  @param URL           请求地址
*  @param parameters    请求参数
*  @param cachePolicy   缓存策略
*  @param callback      请求的回调
*
*  @return 返回的对象可取消请求,调用cancel方法
*/
+ (__kindof NSURLSessionTask *)GET:(NSString *)URL
parameters:(NSDictionary *)parameters
cachePolicy:(XYNetworkingCachePolicy)cachePolicy
callback:(XYHttpRequestBlock)callback;

......


```

