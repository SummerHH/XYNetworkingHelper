//
//  XYNetworkingHelper.h
//  ProjectUkitSet
//
//  Created by xiaoye on 2018/7/5.
//  Copyright © 2018年 ixiye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import <AFNetworkActivityIndicatorManager.h>
#import "XYNetworkRequest.h"
#import "XYNetworkResponse.h"
#import "NSDictionary+XYNetworking.h"
#import "XYNetworkingEnum.h"

/**请求超时时间*/
typedef NSTimeInterval XYRequestTimeoutInterval;

/**请求的Block*/
typedef void(^XYHttpRequestBlock)(XYNetworkRequest *request, XYNetworkResponse *responseObject, BOOL isFromCache);

/**下载的Block*/
typedef void(^XYHttpDownloadBlock)(NSString *filePath, NSError *error);

/*上传或者下载的进度*/
typedef void(^XYHttpProgressBlock)(NSProgress *progress);

/**网络状态Block*/
typedef void(^XYNetworkingStatus)(XYNetworkingStatusType status);


@interface XYNetworkingHelper : NSObject

/**设置接口根路径, 设置后所有的网络访问都使用相对路径 尽量以"/"结束*/
+ (void)setBaseURL:(NSString *)baseURL;

/**设置接口基本参数(如:用户ID, Token)*/
+ (void)setBaseParameters:(NSDictionary *)parameters;

#pragma mark - Network Status

/**实时获取网络状态,通过Block回调实时获取(此方法可多次调用)*/
+ (void)networkStatusWithBlock:(XYNetworkingStatus)networkStatus;

/**判断是否有网*/
+ (BOOL)isNetwork;

/**是否是手机网络*/
+ (BOOL)isWWANNetwork;

/**是否是WiFi网络*/
+ (BOOL)isWiFiNetwork;

/**一次性获取当前网络状态,有网YES,无网:NO*/
+ (BOOL)currentNetworkStatus;

#pragma mark - Cancel Request

/**取消所有Http请求*/
+ (void)cancelAllRequest;

/**取消指定URL的Http请求*/
+ (void)cancelRequestWithURL:(NSString *)url;

#pragma mark - Log

/**
 开启日志打印 (Debug)
 */
+ (void)openLog;

/**
 关闭日志打印
 */
+ (void)closeLog;

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


/**
 *  POST请求,无缓存
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param callback   请求的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)POST:(NSString *)URL
                         parameters:(NSDictionary *)parameters
                           callback:(XYHttpRequestBlock)callback;

/**
 *  POST请求,自动缓存
 *
 *  @param URL           请求地址
 *  @param parameters    请求参数
 *  @param cachePolicy   缓存策略
 *  @param callback      请求的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)POST:(NSString *)URL
                         parameters:(NSDictionary *)parameters
                        cachePolicy:(XYNetworkingCachePolicy)cachePolicy
                           callback:(XYHttpRequestBlock)callback;


/**
 *  PUT请求,无缓存
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param callback   请求的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)PUT:(NSString *)URL
                        parameters:(NSDictionary *)parameters
                          callback:(XYHttpRequestBlock)callback;


/**
 *  PUT请求,自动缓存
 *
 *  @param URL           请求地址
 *  @param parameters    请求参数
 *  @param cachePolicy   缓存策略
 *  @param callback      请求的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+(__kindof NSURLSessionTask *)PUT:(NSString *)URL
                       parameters:(NSDictionary *)parameters
                      cachePolicy:(XYNetworkingCachePolicy)cachePolicy
                         callback:(XYHttpRequestBlock)callback;

/**
 *  DELETE请求,无缓存
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param callback   请求的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)DELETE:(NSString *)URL
                           parameters:(NSDictionary *)parameters
                             callback:(XYHttpRequestBlock)callback;

/**
 *  DELETE请求,自动缓存
 *
 *  @param URL           请求地址
 *  @param parameters    请求参数
 *  @param cachePolicy   缓存策略
 *  @param callback      请求的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+(__kindof NSURLSessionTask *)DELETE:(NSString *)URL
                          parameters:(NSDictionary *)parameters
                         cachePolicy:(XYNetworkingCachePolicy)cachePolicy
                            callback:(XYHttpRequestBlock)callback;


/**
 *  PATCH请求,无缓存
 *
 *  @param URL 请求地址
 *  @param parameters 请求参数
 *  @param callback 请求回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)PATCH:(NSString *)URL
                 parameters:(NSDictionary *)parameters
                   callback:(XYHttpRequestBlock)callback;

/**
 *  PATCH请求,自动缓存
 *
 *  @param URL 请求地址
 *  @param parameters 请求参数
 *  @param cachePolicy   缓存策略
 *  @param callback      请求的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)PATCH:(NSString *)URL
                 parameters:(NSDictionary *)parameters
                cachePolicy:(XYNetworkingCachePolicy)cachePolicy
                   callback:(XYHttpRequestBlock)callback;


/**
 *  HEAD请求,无缓存
 *
 *  @param URL 请求地址
 *  @param parameters 请求参数
 *  @param callback 请求回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)HEAD:(NSString *)URL
                          parameters:(NSDictionary *)parameters
                            callback:(XYHttpRequestBlock)callback;

/**
 *  HEAD请求,自动缓存
 *
 *  @param URL 请求地址
 *  @param parameters 请求参数
 *  @param cachePolicy   缓存策略
 *  @param callback      请求的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)HEAD:(NSString *)URL
                          parameters:(NSDictionary *)parameters
                         cachePolicy:(XYNetworkingCachePolicy)cachePolicy
                            callback:(XYHttpRequestBlock)callback;


/**
 上传文件
 
 @param URL 请求地址
 @param parameters 请求参数
 @param name 文件对应服务器上的字段
 @param filePath 文件本地的沙盒路径
 @param progressBlock 上传进度回调
 @param callback 请求回调
 @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)uploadFileWithURL:(NSString *)URL
                             parameters:(NSDictionary *)parameters
                                   name:(NSString *)name
                               filePath:(NSString *)filePath
                          progressBlock:(XYHttpProgressBlock)progressBlock
                               callback:(void(^)(XYNetworkResponse *responseObject))callback;

/**
 *  上传图片
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param images     图片数组
 *  @param name       文件对应服务器上的字段
 *  @param fileNames  图片文件名数组，传入nil时数组内的文件名默认为当前日期时间戳+索引
 *  @param imageScale 图片文件压缩比 范围 (0.f ~ 1.f)
 *  @param imageType  图片文件的类型,例:png、jpeg(默认类型)....
 *  @param progress   上传进度信息
 *  @param callback   请求回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)uploadWithURL:(NSString *)URL
                                  parameters:(NSDictionary *)parameters
                                      images:(NSArray<UIImage *> *)images
                                        name:(NSString *)name
                                   fileNames:(NSArray<NSString *> *)fileNames
                                  imageScale:(CGFloat)imageScale
                                    imageType:(NSString *)imageType
                                    progress:(XYHttpProgressBlock)progress
                                    callback:(void(^)(XYNetworkResponse *respone))callback;

/**
 *  下载文件
 *
 *  @param URL      请求地址
 *  @param fileDir  文件存储目录(默认存储目录为Download)
 *  @param progress 文件下载的进度信息
 *  @param callback 下载结果回调(回调参数filePath:文件的路径)
 *
 *  @return 返回NSURLSessionDownloadTask实例，可用于暂停继续，暂停调用suspend方法，开始下载调用resume方法
 */
+ (__kindof NSURLSessionTask *)downloadWithURL:(NSString *)URL
                                       fileDir:(NSString *)fileDir
                                      progress:(XYHttpProgressBlock)progress
                                      callback:(XYHttpDownloadBlock)callback;


#pragma mark - 重置AFHTTPSessionManager相关属性
/**
 *  设置网络请求参数的格式:默认为JSON格式
 *
 *  @param requestSerializer NetRequestSerializerJSON(JSON格式),NetRequestSerializerHTTP(二进制格式),
 */
+ (void)setRequestSerializer:(XYNetRequestSerializer)requestSerializer;

/**
 *  设置服务器响应数据格式:默认为JSON格式
 *
 *  @param responseSerializer NetResponseSerializerJSON(JSON格式),NetResponseSerializerHTTP(二进制格式)
 */
+ (void)setResponseSerializer:(XYNetResponseSerializer)responseSerializer;

/**
 *  设置请求超时时间:默认为20S
 *
 *  @param time 时长
 */
+ (void)setRequestTimeoutInterval:(NSTimeInterval)time;

/**
 *  设置请求头
 */
+ (void)setHttpHeaderFieldDictionary:(NSDictionary *)httpHeaderFieldDictionary;

/**
 *  删除所有请求头
 */
+ (void)clearAuthorizationHeader;

/**
 *  是否打开网络状态转圈菊花:默认打开
 *
 *  @param open YES(打开), NO(关闭)
 */
+ (void)openNetworkActivityIndicator:(BOOL)open;

/**
 配置自建证书的Https请求，参考链接:http://blog.csdn.net/syg90178aw/article/details/52839103
 
 @param cerPath 自建https证书路径
 @param validatesDomainName 是否验证域名(默认YES) 如果证书的域名与请求的域名不一致，需设置为NO
 服务器使用其他信任机构颁发的证书也可以建立连接，但这个非常危险，建议打开 .validatesDomainName=NO,主要用于这种情况:客户端请求的是子域名，而证书上是另外一个域名。因为SSL证书上的域名是独立的
 For example:证书注册的域名是www.baidu.com,那么mail.baidu.com是无法验证通过的
 */
+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName;


@end
