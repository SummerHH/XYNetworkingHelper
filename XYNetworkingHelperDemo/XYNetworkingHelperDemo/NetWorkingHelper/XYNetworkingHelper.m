//
//  XYNetworkingHelper.m
//  ProjectUkitSet
//
//  Created by xiaoye on 2018/7/5.
//  Copyright © 2018年 ixiye. All rights reserved.
//

#import "XYNetworkingHelper.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "XYNetWorkingCache.h"
#import "XYNetworkSessionManager.h"

#define KNetworkSessionTask(Method,CachePolicy) [self request:[XYNetworkRequest requestWithUrlStr:URL method:Method cachePolicy:CachePolicy params:parameters] callback:callback]


static BOOL _isNetWorking;
static BOOL _isOpenLog;
static NSString * _baseURL;
static NSDictionary *_baseParameters;
static NSMutableArray<NSURLSessionTask *> *_allSessionTask;

static XYNetworkSessionManager * _sessionManager;

static XYNetRequestSerializer _networkRequestSerializer;           // 请求序列化格式
static XYNetResponseSerializer _networkResponseSerializer;         // 响应反序列化格式
static XYRequestTimeoutInterval _networkRequestTimeoutInterval; // 请求超时时间
static NSDictionary *_networkHeader;                            // 全局请求头

@implementation XYNetworkingHelper

#pragma mark - 初始化AFHTTPSessionManager相关属性
+ (void)initialize {
    
    _sessionManager = [XYNetworkSessionManager manager];
    //设置请求的超时时间
    _sessionManager.requestSerializer.timeoutInterval = 30.f;
    
    //设置服务器返回结果的类型:JSON(AFJSONResponseSerializer,AFHTTPResponseSerializer)
    _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
    
    _sessionManager.securityPolicy.allowInvalidCertificates = YES;
    _sessionManager.securityPolicy.validatesDomainName = NO;
    //打开状态栏的等待菊花
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

}

/**设置接口根路径, 设置后所有的网络访问都使用相对路径*/
+ (void)setBaseURL:(NSString *)baseURL {
    _baseURL = baseURL;
}

/**设置接口基本参数*/
+ (void)setBaseParameters:(NSDictionary *)parameters {
    _baseParameters = parameters;
}

#pragma mark - 重置AFHTTPSessionManager相关属性
+ (void)setRequestSerializer:(XYNetRequestSerializer)requestSerializer {
    _sessionManager.requestSerializer = requestSerializer == XYNetRequestSerializerHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
    _networkRequestSerializer = requestSerializer;
}

+ (void)setResponseSerializer:(XYNetResponseSerializer)responseSerializer {
    _sessionManager.responseSerializer = responseSerializer == XYNetResponseSerializerHTTP ? [AFHTTPResponseSerializer serializer] : [AFJSONResponseSerializer serializer];
    _networkResponseSerializer = responseSerializer;
}

+ (void)setRequestTimeoutInterval:(NSTimeInterval)time {
    _sessionManager.requestSerializer.timeoutInterval = time;
    _networkRequestTimeoutInterval = time;
}

+ (void)setHttpHeaderFieldDictionary:(NSDictionary *)httpHeaderFieldDictionary {
   
    if (![httpHeaderFieldDictionary isKindOfClass:[NSDictionary class]]) {
        NSLog(@"请求头数据有误，请检查！");
        return;
    }
    
    if (httpHeaderFieldDictionary) {
        [httpHeaderFieldDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self setValue:obj forHTTPHeaderField:key];

        }];
    }
}

+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    
    [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
    if (!_networkHeader) {
        _networkHeader = [NSDictionary dictionaryWithObject:value forKey:field];
    } else {
        NSMutableDictionary *headerTemp = [NSMutableDictionary dictionaryWithDictionary:_networkHeader];
        headerTemp[field] = value;
        _networkHeader = [headerTemp copy];
    }
}

+ (void)clearAuthorizationHeader {
    
    [_sessionManager.requestSerializer clearAuthorizationHeader];
    _networkHeader = nil;
}

+ (void)openNetworkActivityIndicator:(BOOL)open {
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:open];
}

+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName {
    
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    //使用证书验证模式
    AFSecurityPolicy *securitypolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    //如果需要验证自建证书(无效证书)，需要设置为YES
    securitypolicy.allowInvalidCertificates = YES;
    //是否需要验证域名，默认为YES
    securitypolicy.validatesDomainName = validatesDomainName;
    securitypolicy.pinnedCertificates = [[NSSet alloc]initWithObjects:cerData, nil];
    [_sessionManager setSecurityPolicy:securitypolicy];
}


#pragma mark - 开始监听网络状态
+ (void)networkStatusWithBlock:(XYNetworkingStatus)networkStatus {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        /*! 1.获得网络监控的管理者 */
        AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
        
        /*! 2.设置网络状态改变后的处理 */
        [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            /*! 当网络状态改变了, 就会调用这个block */
            switch (status)
            {
                case AFNetworkReachabilityStatusUnknown:
                    NSLog(@"未知网络");
                    _isNetWorking = NO;
                    networkStatus ? networkStatus(XYNetworkingStatusUnKnown) : nil;
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    _isNetWorking = NO;
                    NSLog(@"没有网络");
                    networkStatus ? networkStatus(XYNetworkingStatusNotReachable) : nil;
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    _isNetWorking = YES;
                    NSLog(@"手机自带网络");
                    networkStatus ? networkStatus(XYNetworkingStatusReachableViaWWAN) : nil;
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    _isNetWorking = YES;
                    NSLog(@"wifi 网络");
                    networkStatus ? networkStatus(XYNetworkingStatusReachableViaWiFi) : nil;
                    break;
            }
        }];
        [reachabilityManager startMonitoring];
    });
}
/*判断是否有网*/
+ (BOOL)isNetwork{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

/*是否是手机网络*/
+ (BOOL)isWWANNetwork{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWWAN;
}

/*是否是WiFi网络*/
+ (BOOL)isWiFiNetwork{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}

/*是否有网*/
+ (BOOL)currentNetworkStatus {
    return _isNetWorking;
}

#pragma mark - Log

+ (void)openLog {
    _isOpenLog = YES;
}

+ (void)closeLog {
    _isOpenLog = NO;
}

#pragma mark - Cancel Request
+ (void)cancelAllRequest {
    @synchronized(self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [self.allSessionTask removeAllObjects];
    }
}

+ (void)cancelRequestWithURL:(NSString *)URL {
    if (!URL) return;
    @synchronized (self) {
        [self.allSessionTask enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task.currentRequest.URL.absoluteString hasPrefix:URL]) {
                [task cancel];
                [self.allSessionTask removeObject:task];
                *stop = YES;
            }
        }];
    }
}

#pragma mark -- 缓存描述文字
+ (NSString *)cachePolicyStr:(XYNetworkingCachePolicy)cachePolicy {
    switch (cachePolicy) {
        case XYNetworkingCachePolicyIgnoreCache:
            return @"只从网络获取数据，且数据不会缓存在本地";
            break;
        case XYNetworkingCachePolicyCacheOnly:
            return @"只从缓存读数据，如果缓存没有数据，返回一个空";
            break;
        case XYNetworkingCachePolicyNetworkOnly:
            return @"先从网络获取数据，同时会在本地缓存数据";
            break;
        case XYNetworkingCachePolicyCacheElseNetwork:
            return @"先从缓存读取数据，如果没有再从网络获取";
            break;
        case XYNetworkingCachePolicyNetworkElseCache:
            return @"先从网络获取数据，如果没有再从缓存读取数据";
            break;
        case XYNetworkingCachePolicyCacheThenNetwork:
            return @"先从缓存读取数据，然后再从网络获取数据，Block将产生两次调用";
            break;
            
        default:
            return @"未知缓存策略，采用HDCachePolicyIgnoreCache策略";
            break;
    }
}

+ (NSString *)getMethodStr:(XYNetworkingRequestMethod)method{
    switch (method) {
        case XYNetworkingRequestMethodGET:
            return @"GET";
            break;
        case XYNetworkingRequestMethodPOST:
            return @"POST";
            break;
        case XYNetworkingRequestMethodHEAD:
            return @"HEAD";
            break;
        case XYNetworkingRequestMethodPUT:
            return @"PUT";
            break;
        case XYNetworkingRequestMethodPATCH:
            return @"PATCH";
            break;
        case XYNetworkingRequestMethodDELETE:
            return @"DELETE";
            break;
            
        default:
            break;
    }
}

+ (__kindof NSURLSessionTask *)GET:(NSString *)URL parameters:(NSDictionary *)parameters callback:(XYHttpRequestBlock)callback {
    
    return KNetworkSessionTask(XYNetworkingRequestMethodGET, XYNetworkingCachePolicyIgnoreCache);
}

+ (__kindof NSURLSessionTask *)GET:(NSString *)URL parameters:(NSDictionary *)parameters cachePolicy:(XYNetworkingCachePolicy)cachePolicy callback:(XYHttpRequestBlock)callback {
    
    return KNetworkSessionTask(XYNetworkingRequestMethodGET, cachePolicy);
}

+ (__kindof NSURLSessionTask *)POST:(NSString *)URL parameters:(NSDictionary *)parameters callback:(XYHttpRequestBlock)callback {
   
    return KNetworkSessionTask(XYNetworkingRequestMethodPOST, XYNetworkingCachePolicyIgnoreCache);
}

+ (__kindof NSURLSessionTask *)POST:(NSString *)URL parameters:(NSDictionary *)parameters cachePolicy:(XYNetworkingCachePolicy)cachePolicy callback:(XYHttpRequestBlock)callback {
    
    return KNetworkSessionTask(XYNetworkingRequestMethodPOST, cachePolicy);
}

+ (__kindof NSURLSessionTask *)PUT:(NSString *)URL parameters:(NSDictionary *)parameters callback:(XYHttpRequestBlock)callback {
   
    return KNetworkSessionTask(XYNetworkingRequestMethodPUT, XYNetworkingCachePolicyIgnoreCache);
}

+ (__kindof NSURLSessionTask *)PUT:(NSString *)URL parameters:(NSDictionary *)parameters cachePolicy:(XYNetworkingCachePolicy)cachePolicy callback:(XYHttpRequestBlock)callback {
   
    return KNetworkSessionTask(XYNetworkingRequestMethodPUT, cachePolicy);
}

+ (__kindof NSURLSessionTask *)DELETE:(NSString *)URL parameters:(NSDictionary *)parameters callback:(XYHttpRequestBlock)callback {
   
    return KNetworkSessionTask(XYNetworkingRequestMethodDELETE, XYNetworkingCachePolicyIgnoreCache);
}

+ (__kindof NSURLSessionTask *)DELETE:(NSString *)URL parameters:(NSDictionary *)parameters cachePolicy:(XYNetworkingCachePolicy)cachePolicy callback:(XYHttpRequestBlock)callback {
 
    return KNetworkSessionTask(XYNetworkingRequestMethodDELETE, cachePolicy);
}

+ (__kindof NSURLSessionTask *)PATCH:(NSString *)URL parameters:(NSDictionary *)parameters callback:(XYHttpRequestBlock)callback {
  
    return KNetworkSessionTask(XYNetworkingRequestMethodPATCH, XYNetworkingCachePolicyIgnoreCache);
}

+ (__kindof NSURLSessionTask *)PATCH:(NSString *)URL parameters:(NSDictionary *)parameters cachePolicy:(XYNetworkingCachePolicy)cachePolicy callback:(XYHttpRequestBlock)callback {
    
    return KNetworkSessionTask(XYNetworkingRequestMethodPATCH, cachePolicy);
}

+ (__kindof NSURLSessionTask *)HEAD:(NSString *)URL parameters:(NSDictionary *)parameters callback:(XYHttpRequestBlock)callback {
    
    return KNetworkSessionTask(XYNetworkingRequestMethodHEAD, XYNetworkingCachePolicyIgnoreCache);
}

+ (__kindof NSURLSessionTask *)HEAD:(NSString *)URL parameters:(NSDictionary *)parameters cachePolicy:(XYNetworkingCachePolicy)cachePolicy callback:(XYHttpRequestBlock)callback {
    
    return KNetworkSessionTask(XYNetworkingRequestMethodHEAD, cachePolicy);
}

#pragma mark -- 网络请求处理
+ (__kindof NSURLSessionTask *)request:(XYNetworkRequest *)request callback:(XYHttpRequestBlock)callback {
    
    NSAssert(request.urlStr.length, @"XYNetworkRequest Error: URL can not be nil");
    
    if (_baseParameters.count) {
        NSMutableDictionary * mutableBaseParameters = [NSMutableDictionary dictionaryWithDictionary:request.params];
        [mutableBaseParameters addEntriesFromDictionary:_baseParameters];
        request.params = [mutableBaseParameters copy];
    }
    NSString *URL = _baseURL.length ? [NSString stringWithFormat:@"%@%@",_baseURL,request.urlStr] : request.urlStr;
    NSDictionary *parameters = request.params;
    
    request.urlStr = URL;
    request.params = parameters;
    request.header = _networkHeader;
    request.requestSerializer = _networkRequestSerializer;
    request.requestTimeoutInterval = _networkRequestTimeoutInterval;
    
    if (_isOpenLog) {
        NSLog(@"******************** 请求参数 ***************************");
        NSLog(@"请求头: %@\n AFHTTPResponseSerializer：%@ \n 请求方式: %@ \n 缓存策略 = %@ \n 请求URL: %@\n 请求param: %@\n\n",_sessionManager.requestSerializer.HTTPRequestHeaders,_sessionManager.requestSerializer,[self getMethodStr:request.requestMethod],[self cachePolicyStr:request.cachePolicy],URL,parameters);
        NSLog(@"********************************************************");
    }
  
    if (request.cachePolicy == XYNetworkingCachePolicyIgnoreCache) {
        //只从网络获取数据，且数据不会缓存在本地
        NSURLSessionTask *sessionTask = [self dataTaskWithHTTPMethod:request.requestMethod url:URL parameters:parameters callback:^(XYNetworkResponse *responseObject) {
            
            callback ? callback(request,responseObject,NO) : nil;
        }];
        return sessionTask;
    }
    else if (request.cachePolicy == XYNetworkingCachePolicyCacheOnly) {
        //只从缓存读数据，如果缓存没有数据，返回一个空。
        callback ? callback(request,[XYNetworkResponse responseWithRawData:XYNetworkCache(URL, parameters) error:nil],YES) : nil;
        
        //缓存数据 return nil
        return nil;
    }
    else if (request.cachePolicy == XYNetworkingCachePolicyNetworkOnly) {
        //先从网络获取数据，同时会在本地缓存数据
        NSURLSessionTask *sessionTask = [self dataTaskWithHTTPMethod:request.requestMethod url:URL parameters:parameters callback:^(XYNetworkResponse *responseObject) {
            
            callback ? callback(request,responseObject,NO) : nil;
            //对数据异步缓存
            responseObject ? [XYNetWorkingCache setHttpCache:responseObject.rawData URL:URL parameters:parameters] : nil;
            
        }];
        return sessionTask;
    }
    else if (request.cachePolicy == XYNetworkingCachePolicyCacheElseNetwork) {
        //先从缓存读取数据，如果没有再从网络获取
        id responseObject = [XYNetWorkingCache httpCacheForURL:URL parameters:parameters];
        if (responseObject) {
            callback(request,[XYNetworkResponse responseWithRawData:responseObject error:nil],YES);
           
            //缓存数据 return nil
            return nil;
        }
        else {
            NSURLSessionTask *sessionTask = [self dataTaskWithHTTPMethod:request.requestMethod url:URL parameters:parameters callback:^(XYNetworkResponse *responseObject) {
                
                callback ? callback(request,responseObject,NO) : nil;
                //对数据异步缓存
                responseObject ? [XYNetWorkingCache setHttpCache:responseObject.rawData URL:URL parameters:parameters] : nil;
                
            }];
            return sessionTask;
        }
    }
    else if (request.cachePolicy == XYNetworkingCachePolicyNetworkElseCache) {
        //先从网络获取数据，如果没有，此处的没有可以理解为访问网络失败，再从缓存读取
        NSURLSessionTask *sessionTask = [self dataTaskWithHTTPMethod:request.requestMethod url:URL parameters:parameters callback:^(XYNetworkResponse *responseObject) {
            if (responseObject.rawData && !responseObject.error) {
                callback ? callback(request,responseObject,NO) : nil;
                //对数据异步缓存
                responseObject ? [XYNetWorkingCache setHttpCache:responseObject.rawData URL:URL parameters:parameters] : nil;
            }
            else {
                callback ? callback(request,[XYNetworkResponse responseWithRawData:XYNetworkCache(URL, parameters) error:nil],YES) : nil;
            }
        }];
        return sessionTask;
    }
    else if (request.cachePolicy == XYNetworkingCachePolicyCacheThenNetwork) {
        //先从缓存读取数据，然后在本地缓存数据，无论结果如何都会再次从网络获取数据，在这种情况下，Block将产生两次调用
        
        callback ? callback(request,[XYNetworkResponse responseWithRawData:XYNetworkCache(URL, parameters) error:nil],YES) : nil;
        
        NSURLSessionTask *sessionTask = [self dataTaskWithHTTPMethod:request.requestMethod url:URL parameters:parameters callback:^(XYNetworkResponse *responseObject) {
            
            callback ? callback(request,responseObject,NO) : nil;
            //对数据异步缓存
            responseObject ? [XYNetWorkingCache setHttpCache:responseObject.rawData URL:URL parameters:parameters] : nil;
            
        }];
        return sessionTask;
    }
    else {
        //缓存策略错误，将采取 HDCachePolicyIgnoreCache 策略
        NSURLSessionTask *sessionTask = [self dataTaskWithHTTPMethod:request.requestMethod url:URL parameters:parameters callback:^(XYNetworkResponse *responseObject) {
            
            callback ? callback(request,responseObject,NO) : nil;
        }];
        return sessionTask;
    }
}

+ (__kindof NSURLSessionTask *)dataTaskWithHTTPMethod:(XYNetworkingRequestMethod)method url:(NSString *)url parameters:(NSDictionary *)parameters callback:(void(^)(XYNetworkResponse *responseObject))callback {
    
    NSURLSessionTask *sessionTask = [_sessionManager requestWithMethod:[self getMethodStr:method] URLString:url parameters:parameters completion:^(NSURLSessionDataTask *task, XYNetworkResponse *responseObject) {
        
        [self.allSessionTask removeObject:task];
        
        callback ? callback(responseObject) : nil;

        if (_isOpenLog) {
            NSLog(@"\n************************ Fetched Data \n %@ \n ************************ ************************",responseObject.error ? responseObject.error : [responseObject.rawData xy_jsonString]);
        }
    }];
    
    [self.allSessionTask addObject:sessionTask];
    
    return sessionTask;
}

#pragma mark - Upload

+ (__kindof NSURLSessionTask *)uploadFileWithURL:(NSString *)URL
                             parameters:(NSDictionary *)parameters
                                   name:(NSString *)name
                               filePath:(NSString *)filePath
                          progressBlock:(XYHttpProgressBlock)progressBlock
                               callback:(void(^)(XYNetworkResponse *responseObject))callback {
    
    NSURLSessionTask *sessionTask = [_sessionManager uploadWithURLString:URL parameters:parameters constructingBodyWithBlock:^(id<XYMultipartFormData> formData) {
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:name error:&error];
        if (error && callback) {
            callback([XYNetworkResponse responseWithRawData:nil error:error]);
        }
    } progress:^(NSProgress *uploadProgress) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            progressBlock ? progressBlock(uploadProgress) : nil;
        });
    } completion:^(NSURLSessionDataTask *task, XYNetworkResponse *responseObject) {
        
        [self.allSessionTask removeObject:task];
        if (_isOpenLog) {
            NSLog(@"\n************************ Fetched Data \n %@ \n ************************ ************************",responseObject.error ? responseObject.error : [responseObject.rawData xy_jsonString]);

        }
        callback ? callback(responseObject) : nil;
    }];
    
    [self.allSessionTask addObject:sessionTask];
    
    return sessionTask;
}

+ (__kindof NSURLSessionTask *)uploadWithURL:(NSString *)URL
                                  parameters:(NSDictionary *)parameters
                                      images:(NSArray<UIImage *> *)images
                                        name:(NSString *)name
                                   fileNames:(NSArray<NSString *> *)fileNames
                                  imageScale:(CGFloat)imageScale
                                   imageType:(NSString *)imageType
                                    progress:(XYHttpProgressBlock)progress
                                    callback:(void(^)(XYNetworkResponse *responseObject))callback {
   
    NSURLSessionTask *sessionTask = [_sessionManager uploadWithURLString:URL parameters:parameters constructingBodyWithBlock:^(id<XYMultipartFormData> formData) {
       
        //压缩-添加-上传图片
        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
            
            //压缩图片
            NSData *imageData = UIImageJPEGRepresentation(image, imageScale ? imageScale : 0.5);
            // 图片名
            NSString *fileName = fileNames ? [NSString stringWithFormat:@"%@.%@", fileNames[idx], imageType ?: @"jpg"] : [NSString stringWithFormat:@"%f%ld.%@",[[NSDate date] timeIntervalSince1970], (unsigned long)idx, imageType ?: @"jpg"];
            
            // MIME类型
            NSString *mimeType = [NSString stringWithFormat:@"image/%@",imageType ?: @"jpg"];
            // 添加表单数据
            [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:mimeType];
        }];
    } progress:^(NSProgress *uploadProgress) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
        
    } completion:^(NSURLSessionDataTask *task, XYNetworkResponse *responseObject) {
        [self.allSessionTask removeObject:task];
        if (_isOpenLog) {
            
            NSLog(@"\n************************ Fetched Data \n %@ \n ************************ ************************",responseObject.error ? responseObject.error : [responseObject.rawData xy_jsonString]);
        }
        if (callback) {
            callback ? callback(responseObject) : nil;
        }
    }];
    
    [self.allSessionTask addObject:sessionTask];
    
    return sessionTask;
}

+ (__kindof NSURLSessionTask *)downloadWithURL:(NSString *)URL
                                       fileDir:(NSString *)fileDir
                                      progress:(XYHttpProgressBlock)progress
                                      callback:(XYHttpDownloadBlock)callback {
    
    NSURLSessionDownloadTask *downloadTask = [_sessionManager downloadWithURLString:URL fileDir:fileDir progress:^(NSProgress *downloadProgress) {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            progress ? progress(downloadProgress) : nil;
        });
        
    } completion:^(NSString *filePath, NSError *error) {
        if (_isOpenLog) {
            NSLog(@"\n************************ Fetched Data \n %@ \n ************************ ************************",error ? error : filePath);
        }
        
        if (callback) {
            callback(filePath, error);
        }
    }];

    [self.allSessionTask addObject:downloadTask];
    return downloadTask;
}

#pragma mark - Getters && Setters

/**
 存储所有请求task的数组
 */
+ (NSMutableArray *)allSessionTask {
    if (!_allSessionTask) {
        _allSessionTask = [[NSMutableArray alloc] init];
    }
    return _allSessionTask;
}

@end
