//
//  ServerApi.m
//  VcashWallet
//
//  Created by jia zhou on 2019/5/6.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "ServerApi.h"

#define SERVER_URL @"http://47.75.163.56:13515"
//#define SERVER_URL @"http://127.0.0.1:13500"

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
            NSArray* txs = [NSArray modelArrayWithClass:[ServerTransaction class] json:responseObject];
            block?block(YES, txs):nil;
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

-(void)filanizeTransaction:(NSString*)tx_id WithComplete:(RequestCompleteBlock)block{
    NSString* url = [NSString stringWithFormat:@"%@/finalizevcash", SERVER_URL];
    FinalizeTxInfo* info = [FinalizeTxInfo new];
    info.tx_id = tx_id;
    info.code = TxFinalized;
    [[self sessionManager] POST:url parameters:[info modelToJSONObject] progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DDLogInfo(@"---filanizeTransaction suc");
        block?block(YES, nil):nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"---filanizeTransaction failed:%@", error);
        block?block(NO, nil):nil;
    }];
}

-(void)cancelTransaction:(NSString*)tx_id WithComplete:(RequestCompleteBlock)block{
    NSString* url = [NSString stringWithFormat:@"%@/finalizevcash", SERVER_URL];
    FinalizeTxInfo* info = [FinalizeTxInfo new];
    info.tx_id = tx_id;
    info.code = TxCanceled;
    [[self sessionManager] POST:url parameters:[info modelToJSONObject] progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DDLogInfo(@"---cancelTransaction suc");
        block?block(YES, nil):nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"---cancelTransaction failed:%@", error);
        block?block(NO, nil):nil;
    }];
}

-(void)closeTransaction:(NSString*)tx_id{
    NSString* url = [NSString stringWithFormat:@"%@/finalizevcash", SERVER_URL];
    FinalizeTxInfo* info = [FinalizeTxInfo new];
    info.tx_id = tx_id;
    info.code = TxClosed;
    [[self sessionManager] POST:url parameters:[info modelToJSONObject] progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DDLogInfo(@"---closeTransaction suc");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"---closeTransaction failed:%@", error);
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
