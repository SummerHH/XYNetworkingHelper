//
//  XYNetworkingViewController.m
//  ProjectUkitSet
//
//  Created by xiaoye on 2018/7/6.
//  Copyright © 2018年 ixiye. All rights reserved.
//

#import "XYNetworkingViewController.h"
#import "NSDictionary+XYNetworking.h"
#import "XYNetWorkingCache.h"
#import "XYNetworkingHelper.h"
#import <MJExtension.h>

@interface XYNetworkingViewController ()

@property (strong, nonatomic) IBOutlet UILabel *networkLab;
@property (strong, nonatomic) IBOutlet UITextView *responeText;
@property (strong, nonatomic) IBOutlet UITextView *requestTest;

@end

@implementation XYNetworkingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //开启日志
    [XYNetworkingHelper openLog];
    //设置请求超时时间
    [XYNetworkingHelper setRequestTimeoutInterval:30];
    //设置请求的路径
    [XYNetworkingHelper setBaseURL:@"https://api.ciguang.tv/api/v2/"];
    //设置接口基本参数,每个接口必传参数
    NSDictionary *baseParams = @{
                                 @"v":@"2",
                                 @"client":@"ios"
                                 };
    [XYNetworkingHelper setBaseParameters:baseParams];
    
    //监听网络
    [XYNetworkingHelper networkStatusWithBlock:^(XYNetworkingStatusType status) {
        if (status == XYNetworkingStatusUnKnown) {
            self.networkLab.text = @"未知网络";
        }
        else if (status == XYNetworkingStatusNotReachable) {
            self.networkLab.text = @"没有网络";
        }
        else if (status == XYNetworkingStatusReachableViaWWAN) {
            self.networkLab.text = @"手机网络";
        }
        else if (status == XYNetworkingStatusReachableViaWiFi) {
            self.networkLab.text = @"WIFI网络";
        }
    }];
    
}

- (IBAction)getNotCacheBtnClick:(UIButton *)sender {
    
    NSDictionary *param = @{
                            @"album_id" : @(11),
                            @"page" : @(1)
                            };
    
    [XYNetworkingHelper setRequestSerializer:XYNetRequestSerializerHTTP];
    [XYNetworkingHelper GET:@"radio/infolist" parameters:param callback:^(XYNetworkRequest *request, XYNetworkResponse *responseObject, BOOL isFromCache) {
        
        self.requestTest.text = [request mj_JSONString];
        
        NSDictionary *response = responseObject.rawData;
        NSInteger code = [response[@"code"] integerValue];
        if (code == 1) {
            self.responeText.text = [responseObject mj_JSONString];
        }
    }];
}

/**先从缓存读取数据，如果没有再从网络获取*/
- (IBAction)getCacheBtnClick:(UIButton *)sender {
    
    NSDictionary *param = @{
                            @"album_id" : @(11),
                            @"page" : @(1)
                            };
    
    [XYNetworkingHelper setRequestSerializer:XYNetRequestSerializerHTTP];
    [XYNetworkingHelper GET:@"radio/infolist" parameters:param cachePolicy:XYNetworkingCachePolicyCacheElseNetwork callback:^(XYNetworkRequest *request, XYNetworkResponse *responseObject, BOOL isFromCache) {
        self.requestTest.text = [request mj_JSONString];
        
        NSDictionary *response = responseObject.rawData;
        NSInteger code = [response[@"code"] integerValue];
        if (code == 1) {
            self.responeText.text = [responseObject mj_JSONString];
        }
    }];
}

- (IBAction)postNotCacheBtnClick:(UIButton *)sender {

    [XYNetworkingHelper setRequestSerializer:XYNetRequestSerializerHTTP];
    [XYNetworkingHelper POST:@"essence/category" parameters:nil callback:^(XYNetworkRequest *request, XYNetworkResponse *responseObject, BOOL isFromCache) {
        
        self.requestTest.text = [request mj_JSONString];
        
        NSDictionary *response = responseObject.rawData;
        NSInteger code = [response[@"code"] integerValue];
        if (code == 1) {
            self.responeText.text = [responseObject mj_JSONString];
        }
        
    }];
    
}

/**先从缓存读取数据，然后在从网络获取并且缓存，在这种情况下，Block将产生两次调用*/

- (IBAction)postCacheBtnClick:(UIButton *)sender {

    [XYNetworkingHelper setRequestSerializer:XYNetRequestSerializerHTTP];
    [XYNetworkingHelper POST:@"essence/category" parameters:nil cachePolicy:XYNetworkingCachePolicyCacheThenNetwork callback:^(XYNetworkRequest *request, XYNetworkResponse *responseObject, BOOL isFromCache) {
        self.requestTest.text = [request mj_JSONString];
        
        NSDictionary *response = responseObject.rawData;
        NSInteger code = [response[@"code"] integerValue];
        if (code == 1) {
            self.responeText.text = [responseObject mj_JSONString];
        }
    }];
    
}

- (IBAction)clearCacheBtnClick:(UIButton *)sender {
    
    [XYNetWorkingCache removeAllHttpCacheBlock:^(int removedCount, int totalCount) {
       
//        NSLog(@"-----%d----%d",removedCount,totalCount);
        
    } endBlock:^(BOOL error) {
        
        if (!error) {
            NSLog(@"清除完成");
        }
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
