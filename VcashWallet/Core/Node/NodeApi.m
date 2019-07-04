//
//  NodeApi.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/22.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "NodeApi.h"
#import "VcashWallet.h"

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
    return @"http://47.75.163.56:13513";
#else
    return @"https://api-node.vcashwallet.app";
#endif
}

-(void)getOutputsByPmmrIndex:(uint64_t)startheight retArr:(NSMutableArray*)retArr WithComplete:(RequestCompleteBlock)completeblock{
    if (!retArr){
        return;
    }
    NSString* url = [NSString stringWithFormat:@"%@/v1/txhashset/outputs?start_index=%lld&max=500", [self NodeUrl], startheight];
    
    [[self sessionManager] GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NodeOutputs* outputs = [NodeOutputs modelWithJSON:responseObject];
        DDLogWarn(@"-----------getOutputsByPmmrIndex:height = %lld, size = %lu", outputs.last_retrieved_index, (unsigned long)outputs.outputs.count);
        for (NodeOutput* item in outputs.outputs){
            VcashOutput* vcashOutput = [[VcashWallet shareInstance] identifyUtxoOutput:item];
            if (vcashOutput){
                [retArr addObject:vcashOutput];
            }
        }
        if (outputs.highest_index > outputs.last_retrieved_index){
            [self getOutputsByPmmrIndex:outputs.last_retrieved_index retArr:retArr WithComplete:completeblock];
            double percent = (double)outputs.last_retrieved_index / (double)outputs.highest_index;
            completeblock?completeblock(YES, @(percent)):nil;
        }
        else if(outputs.highest_index == outputs.last_retrieved_index){
            completeblock?completeblock(YES, retArr):nil;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"getutxo failed:%@", error);
        completeblock?completeblock(NO, nil):nil;
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

-(uint64_t)getChainHeightWithComplete:(RequestCompleteBlock)completeblock{
    static uint64_t curHeight = 0;
    static NSTimeInterval lastFetch = 0;
    if ([[NSDate date] timeIntervalSince1970] - lastFetch  > 10){
        NSString* url = [NSString stringWithFormat:@"%@/v1/chain", [self NodeUrl]];
        [[self sessionManager] GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NodeChainInfo* info = [NodeChainInfo modelWithJSON:responseObject];
            curHeight = info.height;
            completeblock?completeblock(YES, info):nil;
            lastFetch = [[NSDate date] timeIntervalSince1970];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            DDLogError(@"getChainHeight failed:%@", error);
            completeblock?completeblock(NO, nil):nil;
            lastFetch = 0;
        }];
    }

    return curHeight;
}

-(void)postTx:(NSString*)txHex WithComplete:(RequestCompleteBlock)completeblock{
    if (!txHex){
        return;
    }
    
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
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.securityPolicy.allowInvalidCertificates = YES;
        _sessionManager.securityPolicy.validatesDomainName = NO;
    }
    return _sessionManager;
}

@end
