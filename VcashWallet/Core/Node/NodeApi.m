//
//  NodeApi.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/22.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "NodeApi.h"
#import "VcashWallet.h"
#import "JsonRpc.h"

@implementation NodeApi
{
    AFHTTPSessionManager *_sessionManager;
}

+ (instancetype)shareInstance{
    static id config = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        config = [[self alloc] init];
    });
    return config;
}

-(NSString*)NodeUrl{
#ifdef isInTestNet
    return @"http://127.0.0.1:13513";
#else
    return @"https://api-node.vcashwallet.app";
#endif
}

-(void)getOutputsByPmmrIndex:(uint64_t)startIndex WithComplete:(RequestCompleteBlock)completeblock{
    static NSMutableArray* retArr;
    if (!retArr){
        retArr = [NSMutableArray new];
    } else if (startIndex == 0){
        [retArr removeAllObjects];
    }
    NSString* url = [NSString stringWithFormat:@"%@/v1/txhashset/outputs?start_index=%lld&max=800", [self NodeUrl], startIndex];
    DDLogWarn(@"start request:%@", url);
    
    [[self sessionManager] GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NodeOutputs* outputs = [NodeOutputs modelWithJSON:responseObject];
        DDLogWarn(@"-----------getOutputsByPmmrIndex:last_retrieved_index = %lld, highest_index = %lld, size = %lu", outputs.last_retrieved_index, outputs.highest_index, (unsigned long)outputs.outputs.count);
        for (NodeOutput* item in outputs.outputs){
            VcashOutput* vcashOutput = [[VcashWallet shareInstance] identifyUtxoOutput:item];
            if (vcashOutput){
                [retArr addObject:vcashOutput];
            }
        }
        if (outputs.highest_index > outputs.last_retrieved_index){
            [self getOutputsByPmmrIndex:outputs.last_retrieved_index WithComplete:completeblock];
            double percent = (double)outputs.last_retrieved_index / (double)outputs.highest_index;
            completeblock?completeblock(YES, @(percent)):nil;
        }
        else if(outputs.highest_index <= outputs.last_retrieved_index){
            completeblock?completeblock(YES, retArr):nil;
            retArr = nil;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"getOutputsByPmmrIndex failed, index=%@", @(startIndex));
        completeblock?completeblock(NO, @(startIndex)):nil;
    }];
}

-(void)getTokenOutputsByPmmrIndex:(uint64_t)startIndex WithComplete:(RequestCompleteBlock)completeblock{
    static NSMutableArray* retArr;
    if (!retArr){
        retArr = [NSMutableArray new];
    } else if (startIndex == 0){
        [retArr removeAllObjects];
    }
    NSString* url = [NSString stringWithFormat:@"%@/v1/txhashset/tokenoutputs?start_index=%lld&max=800", [self NodeUrl], startIndex];
    DDLogWarn(@"start request:%@", url);
    
    [[self sessionManager] GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NodeOutputs* outputs = [NodeOutputs modelWithJSON:responseObject];
        DDLogWarn(@"-----------getTokenOutputsByPmmrIndex:height = %lld, size = %lu", outputs.last_retrieved_index, (unsigned long)outputs.outputs.count);
        for (NodeOutput* item in outputs.outputs){
            VcashTokenOutput* vcashOutput = [[VcashWallet shareInstance] identifyUtxoOutput:item];
            if (vcashOutput){
                [retArr addObject:vcashOutput];
            }
        }
        if (outputs.highest_index > outputs.last_retrieved_index){
            [self getTokenOutputsByPmmrIndex:outputs.last_retrieved_index WithComplete:completeblock];
            double percent = (double)outputs.last_retrieved_index / (double)outputs.highest_index;
            completeblock?completeblock(YES, @(percent)):nil;
        }
        else if(outputs.highest_index <= outputs.last_retrieved_index){
            completeblock?completeblock(YES, retArr):nil;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"getTokenOutputsByPmmrIndex failed, index=%@", @(startIndex));
        completeblock?completeblock(NO, @(startIndex)):nil;
    }];
}

-(void)getOutputsByCommitArr:(NSArray<NSString*>*)commitArr WithComplete:(RequestCompleteBlock)completeblock{
    if (!commitArr){
        return;
    }
    NSString* param = [commitArr componentsJoinedByString:@","];
    NSString* url = [NSString stringWithFormat:@"%@/v1/chain/outputs/byids?id=%@", [self NodeUrl], param];
    
    [[self sessionManager] GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray* outputs = [NSArray modelArrayWithClass:[NodeRefreshOutput class] json:responseObject];
        completeblock?completeblock(YES, outputs):nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"getOutputsByCommitArr failed:%@", error);
        completeblock?completeblock(NO, nil):nil;
    }];
}

-(void)getTokenOutputsForToken:(NSString*)token_type WithCommitArr:(NSArray<NSString*>*)commitArr WithComplete:(RequestCompleteBlock)completeblock{
    if (!commitArr || !token_type){
        return;
    }
    NSString* param = [commitArr componentsJoinedByString:@","];
    NSString* url = [NSString stringWithFormat:@"%@/v1/chain/tokenoutputs/byids?token_type=%@&id=%@", [self NodeUrl], token_type, param];
    
    [[self sessionManager] GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray* outputs = [NSArray modelArrayWithClass:[NodeRefreshTokenOutput class] json:responseObject];
        completeblock?completeblock(YES, outputs):nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"getOutputsByCommitArr failed:%@", error);
        completeblock?completeblock(NO, nil):nil;
    }];
}

-(void)getKernel:(NSString*)excess WithComplete:(RequestCompleteBlock)completeblock{
    JsonRpc* rpc = [[JsonRpc alloc] initWithMethod:@"get_kernel" andParamArr:[NSArray arrayWithObjects:excess, [NSNull null], [NSNull null], nil]];
    NSString* param = [rpc modelToJSONObject];
    NSString* url = [NSString stringWithFormat:@"%@/v2/foreign", [self NodeUrl]];
    [[self sessionManager] POST:url parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString*resStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        JsonRpcRes* res = [JsonRpcRes modelWithJSON:resStr];
        NSString* kernelStr = res.result[@"Ok"];
        if (res.error || !kernelStr){
            DDLogError(@"getKernel failed:%@", res.error);
            completeblock?completeblock(NO, nil):nil;
        } else {
            DDLogInfo(@"getKernel suc:%@", kernelStr);
            TxKernel* kernel = [TxKernel modelWithJSON:kernelStr];
            completeblock?completeblock(YES, kernel):nil;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"getKernel failed:%@", error);
        completeblock?completeblock(NO, nil):nil;
    }];
}

-(void)getTokenKernel:(NSString*)tokenExcess WithComplete:(RequestCompleteBlock)completeblock{
    JsonRpc* rpc = [[JsonRpc alloc] initWithMethod:@"get_token_kernel" andParamArr:[NSArray arrayWithObjects:tokenExcess, [NSNull null], [NSNull null], nil]];
    NSString* param = [rpc modelToJSONObject];
    NSString* url = [NSString stringWithFormat:@"%@/v2/foreign", [self NodeUrl]];
    [[self sessionManager] POST:url parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString*resStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        JsonRpcRes* res = [JsonRpcRes modelWithJSON:resStr];
        NSString* kernelStr = res.result[@"Ok"];
        if (res.error || !kernelStr){
            DDLogError(@"getTokenKernel failed:%@", res.error);
            completeblock?completeblock(NO, nil):nil;
        } else {
            
            DDLogInfo(@"getTokenKernel suc:%@", kernelStr);
            TokenTxKernel* kernel = [TokenTxKernel modelWithJSON:kernelStr];
            completeblock?completeblock(YES, kernel):nil;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"getTokenKernel failed:%@", error);
        completeblock?completeblock(NO, nil):nil;
    }];
}

-(uint64_t)getChainHeightWithComplete:(RequestCompleteBlock)completeblock{
    static uint64_t curHeight = 0;
    static NSTimeInterval lastFetch = 0;
    if ([[NSDate date] timeIntervalSince1970] - lastFetch  > 10){
        JsonRpc* rpc = [[JsonRpc alloc] initWithMethod:@"get_tip" andParamArr:[NSArray new]];
        NSString* param = [rpc modelToJSONObject];
        NSString* url = [NSString stringWithFormat:@"%@/v2/foreign", [self NodeUrl]];
        [[self sessionManager] POST:url parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSString*resStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            JsonRpcRes* res = [JsonRpcRes modelWithJSON:resStr];
            if (res.error){
                DDLogError(@"getChainHeight failed:%@", res.error);
                completeblock?completeblock(NO, nil):nil;
                lastFetch = 0;
            } else {
                NSString* resStr = res.result[@"Ok"];
                DDLogInfo(@"getChainHeight suc:%@", resStr);
                NodeChainInfo* info = [NodeChainInfo modelWithJSON:resStr];
                curHeight = info.height;
                completeblock?completeblock(YES, info):nil;
                lastFetch = [[NSDate date] timeIntervalSince1970];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            DDLogError(@"getChainHeight failed:%@", error);
            completeblock?completeblock(NO, nil):nil;
            lastFetch = 0;
        }];
        
//        [[self sessionManager] GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
//            
//        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NodeChainInfo* info = [NodeChainInfo modelWithJSON:responseObject];
//            curHeight = info.height;
//            completeblock?completeblock(YES, info):nil;
//            lastFetch = [[NSDate date] timeIntervalSince1970];
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            DDLogError(@"getChainHeight failed:%@", error);
//            completeblock?completeblock(NO, nil):nil;
//            lastFetch = 0;
//        }];
    }

    return curHeight;
}

-(void)postTx:(NSString*)txHex WithComplete:(RequestCompleteBlock)completeblock{
    if (!txHex){
        return;
    }
    
//    JsonRpc* rpc = [[JsonRpc alloc] initWithMethod:@"push_transaction" andParamArr:[NSArray arrayWithObjects:txHex, [NSNumber numberWithBool:YES], nil]];
//    NSString* param = [rpc modelToJSONObject];
//    NSString* url = [NSString stringWithFormat:@"%@/v2/foreign", [self NodeUrl]];
//    [[self sessionManager] POST:url parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//        NSString*resStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        JsonRpcRes* res = [JsonRpcRes modelWithJSON:resStr];
//        if (res.error){
//            DDLogError(@"postTx failed:%@", res.error);
//            completeblock?completeblock(NO, nil):nil;
//        } else {
//            DDLogWarn(@"postTx suc!");
//            completeblock?completeblock(YES, nil):nil;
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        DDLogError(@"postTx failed:%@", error);
//        completeblock?completeblock(NO, nil):nil;
//    }];
    
    NSString* url = [NSString stringWithFormat:@"%@/v1/pool/push_tx?fluff", [self NodeUrl]];
    NSDictionary* param = [NSDictionary dictionaryWithObject:txHex forKey:@"tx_hex"];
    [[self sessionManager] POST:url parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DDLogWarn(@"postTx suc!");
        completeblock?completeblock(YES, nil):nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"postTx failed:%@", error);
        completeblock?completeblock(NO, nil):nil;
    }];
}

- (AFHTTPSessionManager *)sessionManager
{
    if (_sessionManager == nil) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _sessionManager.requestSerializer.timeoutInterval = 30.0f;
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.securityPolicy.allowInvalidCertificates = YES;
        _sessionManager.securityPolicy.validatesDomainName = NO;
    }
    return _sessionManager;
}

@end
