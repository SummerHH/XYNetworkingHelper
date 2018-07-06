//
//  XYAPIValidator.h
//  Pods
//
//  Created by cby on 2017/3/9.
//
//

#import <Foundation/Foundation.h>

@interface XYAPIValidator : NSObject

/**
 根据模板判断json数据是否合法

 @param json json
 @param templateData 模板文件
 @return yes 合法 no 不合法
 */
+ (BOOL)apiValidatorForJson:(id)json templateData:(id)templateData;

/**
 json 数据中是否包含null

 @param json json
 @return yes 有 no 无
 */
+ (BOOL)jsonValidatorIsContainNull:(id)json;

/**
 将 json 数据中的 null 转换为字符串 <null>

 @param json json
 @return 转化后的数据
 */
+ (id)handleNullToStringNull:(id)json;

+ (BOOL)checkIsRestfulResponse:(NSDictionary *)responseObject message:(NSString **)errorMessage;

@end
