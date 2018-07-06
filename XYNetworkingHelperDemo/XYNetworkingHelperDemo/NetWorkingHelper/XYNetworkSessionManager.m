//
//  XYNetworkSessionManager.m
//  ProjectUkitSet
//
//  Created by xiaoye on 2018/7/5.
//  Copyright © 2018年 ixiye. All rights reserved.
//

#import "XYNetworkSessionManager.h"

@interface XYNetworkSessionManager() <XYNetWorkSessionManagerProtocol>

@end

@implementation XYNetworkSessionManager

static NSString *const kDefaultDownloadDir = @"XYNetworkDownload";


- (NSURLSessionDataTask *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters completion:(XYNetworkTaskBlock)completion {
    
    __block XYNetworkResponse *responseObject;
    
    NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:method URLString:URLString parameters:parameters uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        responseObject = [XYNetworkResponse responseWithRawData:responseObject error:nil];
        if (completion) {
            completion(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // network error.
        [error setValue:@(-999) forKey:@"code"];
        responseObject = [XYNetworkResponse responseWithRawData:nil error:error];
        if (completion) {
            completion(task, responseObject);
        }
    }];
    
    [dataTask resume];
    
    return dataTask;
}


- (NSURLSessionDataTask *)uploadWithURLString:(NSString *)URLString parameters:(id)parameters constructingBodyWithBlock:(void (^)(id<XYMultipartFormData>))block progress:(void (^)(NSProgress *))uploadProgress completion:(XYNetworkTaskBlock)completion {
    
    __block XYNetworkResponse *responseObject;
    
    return [self POST:URLString parameters:parameters constructingBodyWithBlock:block progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        responseObject = [XYNetworkResponse responseWithRawData:responseObject error:nil];
        if (completion) {
            completion(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        responseObject = [XYNetworkResponse responseWithRawData:nil error:error];
        if (completion) {
            completion(task, responseObject);
        }
    }];
}

- (NSURLSessionDownloadTask *)downloadWithURLString:(NSString *)URLString fileDir:(NSString *)fileDir progress:(void (^)(NSProgress *))downloadProgressBlock completion:(void (^)(NSString *, NSError *))completion {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    
    NSURLSessionDownloadTask *downloadTask = [self downloadTaskWithRequest:request progress:downloadProgressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
      
        //拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir ? fileDir : kDefaultDownloadDir];
        
        //打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //创建Download目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        
        //拼接文件路径
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        
        NSLog(@"downloadDir = %@",downloadDir);
        
        //返回文件位置的URL路径
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (completion) {
            if (error) {
                completion(nil, error);
            } else {
                completion(filePath.absoluteString, nil);
            }
        }
    }];
    
    [downloadTask resume];
    
    return downloadTask;
}



@end
