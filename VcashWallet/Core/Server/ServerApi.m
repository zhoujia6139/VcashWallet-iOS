//
//  ServerApi.m
//  VcashWallet
//
//  Created by jia zhou on 2019/5/6.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "ServerApi.h"
#import "payment-proof-lib.h"
#include "blake2.h"

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

-(NSString*)ServerUrl{
#ifdef isInTestNet
    //return @"http://127.0.0.1:13500";
    return @"https://api.vcashwallet.app";
#else
    return @"https://api.vcashwallet.app";
#endif
}

-(void)checkStatusForUser:(NSString*)userId WithComplete:(RequestCompleteBlock)block{
    NSString* url = [NSString stringWithFormat:@"%@/statecheck/%@",[self ServerUrl], userId];
    
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
    NSString* url = [NSString stringWithFormat:@"%@/sendvcash", [self ServerUrl]];
//    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
//    NSData* signature = [secp ecdsaSign:[tx msgToSign] seckey:[[VcashWallet shareInstance] getSignerKey]];
    NSData* msgData = [tx msgToSign];
    NSString* signature = [self getSignatureForMsg:msgData];
    if (!signature) {
        return;
    }
    tx.msg_sig = signature;
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
    NSString* url = [NSString stringWithFormat:@"%@/receivevcash", [self ServerUrl]];
//    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
//    NSData* msgsignature = [secp ecdsaSign:[tx msgToSign] seckey:[[VcashWallet shareInstance] getSignerKey]];
//    tx.msg_sig = BTCHexFromData(msgsignature);
//    NSData* txsignature = [secp ecdsaSign:[tx txDataToSign] seckey:[[VcashWallet shareInstance] getSignerKey]];
//    tx.tx_sig = BTCHexFromData(txsignature);
    NSData* msgData = [tx msgToSign];
    NSString* signature = [self getSignatureForMsg:msgData];
    if (!signature) {
        return;
    }
    tx.msg_sig = signature;
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
    NSString* url = [NSString stringWithFormat:@"%@/finalizevcash", [self ServerUrl]];
    FinalizeTxInfo* info = [FinalizeTxInfo new];
    info.tx_id = tx_id;
    info.code = TxFinalized;
//    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
//    NSData* signature = [secp ecdsaSign:[info msgToSign] seckey:[[VcashWallet shareInstance] getSignerKey]];
//    info.msg_sig = BTCHexFromData(signature);
    NSData* msgData = [info msgToSign];
    NSString* signature = [self getSignatureForMsg:msgData];
    if (!signature) {
        return;
    }
    info.msg_sig = signature;
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
    if (!tx_id){
        return;
    }
    NSString* url = [NSString stringWithFormat:@"%@/finalizevcash", [self ServerUrl]];
    FinalizeTxInfo* info = [FinalizeTxInfo new];
    info.tx_id = tx_id;
    info.code = TxCanceled;
//    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
//    NSData* signature = [secp ecdsaSign:[info msgToSign] seckey:[[VcashWallet shareInstance] getSignerKey]];
//    info.msg_sig = BTCHexFromData(signature);
    NSData* msgData = [info msgToSign];
    NSString* signature = [self getSignatureForMsg:msgData];
    if (!signature) {
        return;
    }
    info.msg_sig = signature;
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
    NSString* url = [NSString stringWithFormat:@"%@/finalizevcash", [self ServerUrl]];
    FinalizeTxInfo* info = [FinalizeTxInfo new];
    info.tx_id = tx_id;
    info.code = TxClosed;
//    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
//    NSData* signature = [secp ecdsaSign:[info msgToSign] seckey:[[VcashWallet shareInstance] getSignerKey]];
//    info.msg_sig = BTCHexFromData(signature);
    NSData* msgData = [info msgToSign];
    NSString* signature = [self getSignatureForMsg:msgData];
    if (!signature) {
        return;
    }
    info.msg_sig = signature;
    [[self sessionManager] POST:url parameters:[info modelToJSONObject] progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DDLogInfo(@"---closeTransaction suc");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"---closeTransaction failed:%@", error);
    }];
}

-(NSString*)getSignatureForMsg:(NSData*)msgData {
    uint8_t hash[32];
    if( blake2b( hash, msgData.bytes, nil, 32, msgData.length, 0 ) < 0){
        return nil;
    }
    NSData* msgHashedData = [[NSData alloc] initWithBytes:hash length:32];
    NSString* msgHashedStr = BTCHexFromData(msgHashedData);
    NSString* secKeyStr = [[VcashWallet shareInstance] getSignerKey];
    const char* signatureStr = create_payment_proof_signature([msgHashedStr UTF8String], [secKeyStr UTF8String]);
    NSString* signature = [NSString stringWithUTF8String:signatureStr];
    const char* pubkeyStr = base32_address_to_pubkey_address([[VcashWallet shareInstance].userId UTF8String]);
    bool isValid = verify_payment_proof([msgHashedStr UTF8String], pubkeyStr, signatureStr);
    if (!isValid) {
        DDLogError(@"---Signature is invalid!");
    }
    c_str_free(signatureStr);
    c_str_free(pubkeyStr);
    
    return signature;
}

- (AFHTTPSessionManager *)sessionManager
{
    if (_sessionManager == nil) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _sessionManager.requestSerializer.timeoutInterval = 20.0f;
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.securityPolicy.allowInvalidCertificates = YES;
        _sessionManager.securityPolicy.validatesDomainName = NO;
        
    }
    return _sessionManager;
}

@end
