//
//  ServerApi.m
//  VcashWallet
//
//  Created by jia zhou on 2019/5/6.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "ServerApi.h"

#define SERVER_URL @"http://10.0.0.187:13500"

@implementation ServerApi
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

-(void)checkStatusForUser:(NSString*)userId WithComplete:(RequestCompleteBlock)block{
    NSString* url = [NSString stringWithFormat:@"%@/statecheck/%@", SERVER_URL, userId];
    
    [[self sessionManager] GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject){
            ServerTransaction* tx = [ServerTransaction modelWithJSON:responseObject];
            block?block(YES, tx):nil;
        }
        else{
            block?block(YES, nil):nil;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"---checkStatusForUser failed:%@", error);
        block?block(NO, nil):nil;
    }];
}

-(void)sendTransaction:(ServerTransaction*)tx WithComplete:(RequestCompleteBlock)block{
    NSString* url = [NSString stringWithFormat:@"%@/sendvcash", SERVER_URL];
    [[self sessionManager] POST:url parameters:[tx modelToJSONObject] progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DDLogInfo(@"---sendTransaction suc");
        block?block(YES, nil):nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"---sendTransaction failed:%@", error);
        block?block(NO, nil):nil;
    }];
}

-(void)receiveTransaction:(ServerTransaction*)tx WithComplete:(RequestCompleteBlock)block{
    NSString* url = [NSString stringWithFormat:@"%@/receivevcash", SERVER_URL];
    [[self sessionManager] POST:url parameters:[tx modelToJSONObject] progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DDLogInfo(@"---receiveTransaction suc");
        block?block(YES, nil):nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"---receiveTransaction failed:%@", error);
        block?block(NO, nil):nil;
    }];
}

-(void)filanizeTransaction:(ServerTransaction*)tx{
    NSString* url = [NSString stringWithFormat:@"%@/finalizevcash", SERVER_URL];
    [[self sessionManager] POST:url parameters:[tx modelToJSONObject] progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DDLogInfo(@"---filanizeTransaction suc");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"---filanizeTransaction failed:%@", error);
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
