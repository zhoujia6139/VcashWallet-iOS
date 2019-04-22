//
//  NodeApi.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/22.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "NodeApi.h"
#import "VcashWallet.h"

#define NODE_URL @"http://47.75.163.56:13513"

static AFHTTPSessionManager *_sessionManager;

@implementation NodeApi

+(void)getOutputsByPmmrIndex:(uint64_t)startheight retArr:(NSMutableArray*)retArr WithComplete:(RequestCompleteBlock)completeblock{
    if (!retArr){
        return;
    }
    NSString* url = [NSString stringWithFormat:@"%@/v1/txhashset/outputs?start_index=%lld&max=500", NODE_URL, startheight];
    
    [[self sessionManager] GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NodeOutputs* outputs = [NodeOutputs modelWithJSON:responseObject];
        for (NodeOutput* item in outputs.outputs){
            VcashOutput* vcashOutput = [[VcashWallet shareInstance] identifyUtxoOutput:item];
            if (vcashOutput){
                [retArr addObject:vcashOutput];
            }
        }
        if (outputs.highest_index > outputs.last_retrieved_index){
            [self getOutputsByPmmrIndex:outputs.last_retrieved_index retArr:retArr WithComplete:completeblock];
        }
        else if(outputs.highest_index == outputs.last_retrieved_index){
            if (completeblock){
                completeblock(YES, retArr);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completeblock){
            completeblock(NO, nil);
        }
    }];
}

+ (AFHTTPSessionManager *)sessionManager
{
    if (_sessionManager == nil) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.securityPolicy.allowInvalidCertificates = YES;
        _sessionManager.securityPolicy.validatesDomainName = NO;
    }
    return _sessionManager;
}

@end
