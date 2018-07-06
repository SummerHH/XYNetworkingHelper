//
//  XYAPIValidator.m
//  Pods
//
//  Created by cby on 2017/3/9.
//
//

#import "XYAPIValidator.h"

@implementation XYAPIValidator

+ (BOOL)apiValidatorForJson:(id)json templateData:(id)templateJson
{
    if ([json isKindOfClass:[NSDictionary class]] &&
        [templateJson isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = json;
        NSDictionary *validator = templateJson;
        BOOL result = YES;
        NSEnumerator *enumerator = [validator keyEnumerator];
        NSString *key;
        while ((key = [enumerator nextObject]) != nil)
        {
            id value = dict[key];
            id format = validator[key];
            if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]])
            {
                result = [self apiValidatorForJson:value templateData:format];
                if (!result)
                {
                    break;
                }
            }
            else
            {
                if ([value isKindOfClass:format] == NO &&
                    [value isKindOfClass:[NSNull class]] == NO)
                {
                    result = NO;
                    break;
                }
            }
        }
        return result;
    } else if ([json isKindOfClass:[NSArray class]] && [templateJson isKindOfClass:[NSArray class]]) {
        NSArray *validatorArray = (NSArray *) templateJson;
        if (validatorArray.count > 0)
        {
            NSArray *array = json;
            NSDictionary *validator = templateJson[0];
            for (id item in array)
            {
                BOOL result = [self apiValidatorForJson:item templateData:validator];
                if (!result)
                {
                    return NO;
                }
            }
        }
        return YES;
    }
    else if ([json isKindOfClass:templateJson])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)jsonValidatorIsContainNull:(id)json
{
    if([json isEqual:[NSNull null]] || !json)
    {
        return YES;
    }
    if([json isKindOfClass:[NSDictionary class]])
    {
        NSArray *allValues = [json allValues];
        for (id object in allValues)
        {
            if([XYAPIValidator jsonValidatorIsContainNull:object])
            {
                return YES;
            }
        }
    }
    if([json isKindOfClass:[NSArray class]])
    {
        for (id object in json)
        {
            if([XYAPIValidator jsonValidatorIsContainNull:object])
            {
                return YES;
            }
        }
    }
    return NO;
}

/**
 把 null 转为 @"<null>"
 
 @param json 需要转化的结构
 @return 处理完成后的数据
 */
+ (id)handleNullToStringNull:(id)json {
    if([json isEqual:[NSNull null]] || !json) {
        return @"<null>";
    }
    if([json isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary *mJson = [NSMutableDictionary dictionary];
        NSArray *allKeys = [json allKeys];
        for (NSString *key in allKeys)
        {
            id value = json[key];
            mJson[key] = [XYAPIValidator handleNullToStringNull:value];
        }
        json = [mJson copy];
    }
    if([json isKindOfClass:[NSArray class]])
    {
        NSMutableArray *mJson = [NSMutableArray array];
        for (id object in json)
        {
            [mJson addObject:[XYAPIValidator handleNullToStringNull:object]];
        }
        json = [mJson copy];
    }
    return json;
}

// 检查返回的值是否符合以下两个预期
// 是否为字典
// retCode 是否是 0
+ (BOOL)checkIsRestfulResponse:(NSDictionary *)responseObject message:(NSString **)errorMessage {
    if (![responseObject isKindOfClass:[NSDictionary class]] || !responseObject) {
        // 响应参数不符合预期
        *errorMessage = @"响应参数不符合预期";
        return NO;
    }
    NSString *retCod = responseObject[@"code"];
    if (!retCod) {
        retCod = responseObject[@"retCode"];
        
    }
    if (!retCod) {
        // 响应参数不符合预期
        *errorMessage = [NSString stringWithFormat:@"%@", responseObject[@"msg"]];
        return NO;
    }

    if ([retCod isKindOfClass:[NSString class]]) {
        if ([retCod isEqualToString:@"4011"]) {
           
            return NO;
        }
        return YES;
    } else {
        if ([retCod integerValue] == 4011 ) {
        
            return NO;
        }
        return YES;
    }
    return YES;
}

@end
