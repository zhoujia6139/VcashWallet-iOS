//
//  JsonRpc.m
//  VcashWallet
//
//  Created by jia zhou on 2019/12/9.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "JsonRpc.h"

@implementation JsonRpc

- (id) initWithMethod:(NSString*)method andParamArr:(NSArray*)paramArr {
    if (self = [super init]) {
        _jsonrpc = @"2.0";
        _method = method;
        _num_id = 1;
        _params = paramArr;
    }
    
    return self;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"num_id":@"id",
             };
}

@end

@implementation JsonRpcRes

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"num_id":@"id",
             };
}

@end
