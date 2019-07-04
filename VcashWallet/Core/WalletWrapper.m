//
//  WalletWrapper.m
//  PoolinWallet
//
//  Created by jia zhou on 2018/7/31.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "WalletWrapper.h"
#import "CoreBitcoin.h"
#import "VcashKeyChain.h"
#import "NodeApi.h"
#import "ServerApi.h"

@interface BTCMnemonic (Words)
+(NSArray*) englishWordList;
@end


@implementation WalletWrapper

+(NSArray*)getAllPhraseWords
{
    return [BTCMnemonic englishWordList];
}

+(NSArray*)generateMnemonicPassphrase
{
    BTCMnemonic* mnemonic = [[BTCMnemonic alloc] initWithEntropy:BTCRandomDataWithLength(32) password:nil wordListType:BTCMnemonicWordListTypeEnglish];
    return mnemonic.words;
}

+(BOOL)createWalletWithPhrase:(NSArray*)wordsArr nickname:(NSString*)nickname password:(NSString*)password
{
    BTCMnemonic* mnemonic = [[BTCMnemonic alloc] initWithWords:wordsArr password:password wordListType:BTCMnemonicWordListTypeEnglish];
    if (mnemonic)
    {
        VcashKeyChain* keychain = [[VcashKeyChain alloc] initWithMnemonic:mnemonic];
        [VcashWallet createWalletWithKeyChain:keychain];
        [[UserCenter sharedInstance] writeAppInstallAndCreateWallet:YES];
        //[[BTCWallet shareInstance] reSetMnemonic:mnemonic];
        return YES;
    }

    return NO;
}

+(void)clearWallet
{
    [[VcashDataManager shareInstance] clearAllData];
}

+(NSString*)getWalletUserId{
    return [VcashWallet shareInstance].userId;
}

+(WalletBalanceInfo*)getWalletBalanceInfo{
    return [[VcashWallet shareInstance] getWalletBalanceInfo];
}

+(uint64_t)getCurChainHeight{
    return [VcashWallet shareInstance].curChainHeight;
}

+(void)checkWalletUtxoWithComplete:(RequestCompleteBlock)block{
    NSMutableArray* arr = [NSMutableArray new];
    [[NodeApi shareInstance] getOutputsByPmmrIndex:0 retArr:arr WithComplete:^(BOOL yesOrNo, id result) {
        if (yesOrNo){
            if ([result isKindOfClass:[NSArray class]]){
                NSMutableArray* txArr = [NSMutableArray new];
                for (VcashOutput* item in (NSArray*)result){
                    VcashTxLog* tx = [VcashTxLog new];
                    tx.tx_id = [[VcashWallet shareInstance] getNextLogId];
                    tx.create_time = [[NSDate date] timeIntervalSince1970];
                    tx.confirm_state = NetConfirmed;
                    tx.amount_credited = item.value;
                    tx.tx_type = item.is_coinbase?ConfirmedCoinbase:TxReceived;
                    item.tx_log_id = tx.tx_id;
                    
                    [txArr addObject:tx];
                }
                [[VcashWallet shareInstance] setChainOutputs:(NSArray*)result];
                [[VcashDataManager shareInstance] saveTxDataArr:txArr];
                block?block(YES, txArr):nil;
            }
            else{
                block?block(YES, result):nil;
            }
        }
        else{
            block?block(NO, result):nil;
        }
    }];
}

+(void)createSendTransaction:(uint64_t)amount fee:(uint64_t)fee withComplete:(RequestCompleteBlock)block{
    return [[VcashWallet shareInstance] sendTransaction:amount andFee:fee withComplete:^(BOOL yesOrNO, id data) {
        block?block(yesOrNO, data):nil;
    }];

}

+(void)sendTransaction:(VcashSlate*)slate forUrl:(NSString*)url withComplete:(RequestCompleteBlock)block{
    DDLogWarn(@"sendTransaction for url:%@", url);
    BOOL ret = [[VcashDataManager shareInstance] beginDatabaseTransaction];
    if (!ret){
        DDLogError(@"beginDatabaseTransaction failed");
        block?block(NO, @"Db error"):nil;
        return;
    }
    dispatch_block_t rollbackBlock = ^{
        [[VcashDataManager shareInstance] rollbackDataTransaction];
        [[VcashWallet shareInstance] reloadOutputInfo];
    };
    
    [self sendTx:slate withComplete:^(BOOL yesOrNO, id _Nullable data) {
        if (yesOrNO){
            static AFHTTPSessionManager *sessionManager;
            if (!sessionManager){
                sessionManager = [AFHTTPSessionManager manager];
                sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
                sessionManager.requestSerializer.timeoutInterval = 20.0f;
                sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
                sessionManager.securityPolicy.allowInvalidCertificates = YES;
                sessionManager.securityPolicy.validatesDomainName = NO;
            }
            NSString* postUrl = [NSString stringWithFormat:@"%@/v1/wallet/foreign/receive_tx", url];
            NSString* param = [slate modelToJSONObject];
            [sessionManager POST:postUrl parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                DDLogWarn(@"sendTransaction post to %@ suc!", postUrl);
                NSString*slateStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                if ([slateStr hasPrefix:@"\""]){
                    slateStr = [slateStr stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                    slateStr = [slateStr stringByReplacingCharactersInRange:NSMakeRange(slateStr.length-1, 1) withString:@""];
                    slateStr = [slateStr stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                }
                VcashSlate* resSlate = [VcashSlate modelWithJSON:slateStr];
                [self finalizeTransaction:resSlate withComplete:^(BOOL yesOrNO, id _Nullable data) {
                    if (yesOrNO){
                        DDLogWarn(@"finalizeTransaction sec!");
                        [[VcashDataManager shareInstance] commitDatabaseTransaction];
                        block?block(YES, nil):nil;
                    }
                    else{
                        DDLogError(@"finalizeTransaction failed!");
                        rollbackBlock();
                        block?block(NO, data):nil;
                    }
                }];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                DDLogError(@"sendTx to url failed! url = %@ error = %@", postUrl, error);
                rollbackBlock();
                block?block(NO, nil):nil;
            }];
        }
        else{
            DDLogError(@"sendTx error!");
            rollbackBlock();
            block?block(NO, data):nil;
        }
    }];
}

+(void)sendTransaction:(VcashSlate*)slate forUser:(NSString*)user withComplete:(RequestCompleteBlock)block{
    DDLogWarn(@"sendTransaction for userid:%@", user);
    BOOL ret = [[VcashDataManager shareInstance] beginDatabaseTransaction];
    if (!ret){
        DDLogError(@"beginDatabaseTransaction failed");
        block?block(NO, @"Db error"):nil;
        return;
    }
    dispatch_block_t rollbackBlock = ^{
        [[VcashDataManager shareInstance] rollbackDataTransaction];
        [[VcashWallet shareInstance] reloadOutputInfo];
    };
    
    slate.txLog.parter_id = user;
    [self sendTx:slate withComplete:^(BOOL yesOrNO, id _Nullable data) {
        if (yesOrNO){
            ServerTransaction* server_tx = [[ServerTransaction alloc] initWithSlate:slate];
            server_tx.sender_id = [VcashWallet shareInstance].userId;
            server_tx.receiver_id = user;
            server_tx.status = TxDefaultStatus;
            [[ServerApi shareInstance] sendTransaction:server_tx WithComplete:^(BOOL yesOrNO, id _Nullable data) {
                if (yesOrNO){
                    DDLogInfo(@"-----sendTransaction to server suc");
                    [[VcashDataManager shareInstance] commitDatabaseTransaction];
                    block?block(YES, nil):nil;
                }
                else{
                    DDLogError(@"-----sendTransaction to server failed! roll back database");
                    rollbackBlock();
                    block?block(NO, @"Tx send to server failed"):nil;
                }
            }];
        }
        else{
            DDLogError(@"sendTx error!");
            rollbackBlock();
            block?block(NO, data):nil;
        }
    }];
}

+(void)sendTransactionByFile:(VcashSlate*)slate withComplete:(RequestCompleteBlock)block{
    DDLogWarn(@"start sendTransaction by file");
    BOOL ret = [[VcashDataManager shareInstance] beginDatabaseTransaction];
    if (!ret){
        DDLogError(@"beginDatabaseTransaction failed");
        block?block(NO, @"Db error"):nil;
        return;
    }
    dispatch_block_t rollbackBlock = ^{
        [[VcashDataManager shareInstance] rollbackDataTransaction];
        [[VcashWallet shareInstance] reloadOutputInfo];
    };
    
    [self sendTx:slate withComplete:^(BOOL yesOrNO, id _Nullable data) {
        if (yesOrNO){
            DDLogWarn(@"sendTransaction by file suc");
            [[VcashDataManager shareInstance] commitDatabaseTransaction];
            NSString* str = [slate modelToJSONString];
            block?block(YES, str):nil;
        }
        else{
            DDLogError(@"sendTransaction by file error!");
            rollbackBlock();
            block?block(NO, data):nil;
        }
    }];
}

+(void)sendTx:(VcashSlate*)slate withComplete:(RequestCompleteBlock)block{
    slate.lockOutputsFn?slate.lockOutputsFn():nil;
    slate.createNewOutputsFn?slate.createNewOutputsFn():nil;
    //save txLog
    slate.txLog.status = TxDefaultStatus;
    int ret = [[VcashDataManager shareInstance] saveTx:slate.txLog];
    if (!ret){
        block?block(NO, @"Db error:saveTx failed"):nil;
        return;
    }
    
    //save output status
    [[VcashWallet shareInstance] syncOutputInfo];
    
    //save context
    ret = [[VcashDataManager shareInstance] saveContext:slate.context];
    if (!ret){
        block?block(NO, @"Db error:save context failed"):nil;
        return;
    }
    
    block?block(YES, nil):nil;
    return;
}

+(void)isValidSlateConentForReceive:(NSString*)slateStr withComplete:(RequestCompleteBlock)block{
    VcashSlate* slate = [VcashSlate modelWithJSON:slateStr];
    if (!slate || ![slate isValidForReceive]){
        block?block(NO, @"Wrong Data Format"):nil;
        return;
    }
    
    VcashTxLog* txLog = [[VcashDataManager shareInstance] getTxBySlateId:slate.uuid];
    if (txLog){
        block?block(NO, @"Duplicate Tx"):nil;
        return;
    }
    
    block?block(YES, slate):nil;
}

+(void)isValidSlateConentForFinalize:(NSString*)slateStr withComplete:(RequestCompleteBlock)block{
    VcashSlate* slate = [VcashSlate modelWithJSON:slateStr];
    if (!slate || ![slate isValidForFinalize]){
        block?block(NO, @"Wrong Data Format"):nil;
        return;
    }
    
    VcashTxLog* txLog = [[VcashDataManager shareInstance] getTxBySlateId:slate.uuid];
    if (txLog){
        block?block(NO, @"Duplicate Tx"):nil;
        return;
    }
    
    block?block(YES, slate):nil;
}

+(void)receiveTransactionBySlate:(VcashSlate*)slate withComplete:(RequestCompleteBlock)block{
    [self receiveTx:slate withComplete:^(BOOL yesOrNO, id _Nullable data) {
        block?block(yesOrNO, data):nil;
    }];
}

+(void)receiveTransaction:(ServerTransaction*)tx withComplete:(RequestCompleteBlock)block{
    [self receiveTx:tx withComplete:^(BOOL yesOrNO, id _Nullable data) {
        block?block(yesOrNO, data):nil;
    }];
}

+(void)receiveTx:(NSObject*)obj withComplete:(RequestCompleteBlock)block{
    VcashSlate* slate;
    ServerTransaction* serverTx;
    if ([obj isKindOfClass:[VcashSlate class]]){
        slate = (VcashSlate*)obj;
    }
    else if ([obj isKindOfClass:[ServerTransaction class]]){
        serverTx = (ServerTransaction*)obj;
        slate = serverTx.slateObj;
    }
    
    BOOL ret = [[VcashWallet shareInstance] receiveTransaction:slate];
    if (!ret){
        DDLogError(@"VcashWallet receiveTransaction failed");
        block?block(NO, nil):nil;
        return;
    }
    
    ret = [[VcashDataManager shareInstance] beginDatabaseTransaction];
    if (!ret){
        DDLogError(@"beginDatabaseTransaction failed");
        block?block(NO, @"Db error"):nil;
        return;
    }
    dispatch_block_t rollbackBlock = ^{
        [[VcashDataManager shareInstance] rollbackDataTransaction];
        [[VcashWallet shareInstance] reloadOutputInfo];
    };
    
    slate.createNewOutputsFn?slate.createNewOutputsFn():nil;
    //save txLog
    NSString* slateStr = [slate modelToJSONString];
    slate.txLog.parter_id = serverTx.sender_id;
    slate.txLog.status = TxReceiverd;
    slate.txLog.signed_slate_msg = slateStr;
    ret = [[VcashDataManager shareInstance] saveTx:slate.txLog];
    if (!ret){
        rollbackBlock();
        DDLogError(@"VcashDataManager saveAppendTx failed");
        block?block(NO, @"Db error"):nil;
        return;
    }
    
    //save output status
    [[VcashWallet shareInstance] syncOutputInfo];
    
    if (serverTx){
        serverTx.slate  = slateStr;
        serverTx.status = TxReceiverd;
        [[ServerApi shareInstance] receiveTransaction:serverTx WithComplete:^(BOOL yesOrNO, id _Nullable data) {
            if (yesOrNO){
                DDLogInfo(@"-----send receiveTransaction suc");
                [[VcashDataManager shareInstance] commitDatabaseTransaction];
                block?block(YES, nil):nil;
            }
            else{
                DDLogError(@"-----send receiveTransaction to server failed! roll back database");
                rollbackBlock();
                block?block(NO, nil):nil;
            }
        }];
    }
    else{
        [[VcashDataManager shareInstance] commitDatabaseTransaction];
        block?block(YES, slateStr):nil;
    }
    
    return;
}

+(void)finalizeServerTx:(ServerTransaction*)tx withComplete:(RequestCompleteBlock)block{
    [self finalizeTransaction:tx.slateObj withComplete:^(BOOL yesOrNo, id _Nullable data) {
        if (yesOrNo){
            //tx.slate  = [tx.slateObj modelToJSONString];
            tx.status = TxFinalized;
            [[ServerApi shareInstance] filanizeTransaction:tx.tx_id WithComplete:^(BOOL yesOrNo, id _Nullable data) {
                if (!yesOrNo){
                    DDLogError(@"filalize tx to Server failed, cache tx state");
                }
            }];
            block?block(YES, nil):nil;
        }
        else{
            block?block(NO, data):nil;
        }
    }];
}

+(void)finalizeTransaction:(VcashSlate*)slate withComplete:(RequestCompleteBlock)block{
    VcashContext* context = [[VcashDataManager shareInstance] getContextBySlateId:slate.uuid];
    if (!context){
        DDLogError(@"--------database record is broke, cannot finalize tx");
        block?block(NO, @""):nil;
        return;
    }
    slate.context = context;
    if (![[VcashWallet shareInstance] finalizeTransaction:slate]){
        DDLogError(@"--------finalizeTransaction failed");
        block?block(NO, @""):nil;
        return;
    }
    
    [slate.tx sortTx];
    NSData* txPayload = [slate.tx computePayloadForHash:NO];
    [[NodeApi shareInstance] postTx:BTCHexFromData(txPayload) WithComplete:^(BOOL yesOrNo, id _Nullable data) {
        if (yesOrNo){
            block?block(YES, nil):nil;
            VcashTxLog *txLog = [[VcashDataManager shareInstance] getTxBySlateId:slate.uuid];
            if (txLog){
                txLog.confirm_state = LoalConfirmed;
                txLog.status = TxFinalized;
                [[VcashDataManager shareInstance] saveTx:txLog];
            }
            else{
                DDLogError(@"impossible things happened!can not find tx:%@", slate.uuid);
            }
        }
        else{
            block?block(NO, @"post tx to node failed"):nil;
        }
    }];
    
    return;
}

+(BOOL)cancelTransaction:(NSString*)tx_id{
    VcashTxLog *txLog =  [self getTxByTxid:tx_id];
    if ([txLog isCanBeCanneled] || txLog == nil){
        [txLog cancelTxlog];
        [[VcashDataManager shareInstance] saveTx:txLog];
        
        [[ServerApi shareInstance] cancelTransaction:tx_id WithComplete:^(BOOL yesOrNo, id _Nullable data) {
            if (!yesOrNo){
                DDLogError(@"cancel tx to Server failed");
            }
        }];
        
        return YES;
    }
    
    return NO;
}

+(NSArray*)getTransationArr{
    return [[VcashDataManager shareInstance] getTxData];
}

+(VcashTxLog*)getTxByTxid:(NSString*)txid{
    return [[VcashDataManager shareInstance] getTxBySlateId:txid];
}

+(Boolean)deleteTxByTxid:(NSString*)txid{
    return  [[VcashDataManager shareInstance] deleteTxBySlateId:txid];
}

+(NSArray*)getFileReceiveTxArr{
    NSArray* txArr = [self getTransationArr];
    NSMutableArray* retArr = [NSMutableArray new];
    for (VcashTxLog* item in txArr){
        if (item.tx_type == TxReceived && !item.parter_id && item.signed_slate_msg){
            [retArr addObject:item];
        }
    }
    
    return retArr;
}

+(void)updateOutputStatusWithComplete:(RequestCompleteBlock)block{
    NSMutableArray* strArr = [NSMutableArray new];
    for (VcashOutput* item in [VcashWallet shareInstance].outputs){
        [strArr addObject:item.commitment];
    }
    
    if (strArr.count == 0){
        block?block(YES, nil):nil;
        return;
    }
    
    [[NodeApi shareInstance] getOutputsByCommitArr:strArr WithComplete:^(BOOL yesOrNO, id data) {
        if (yesOrNO){
            NSArray* apiOutputs = data;
            NSArray* txs = [self getTransationArr];
            BOOL hasChange = NO;
            for (VcashOutput* item in [VcashWallet shareInstance].outputs){
                NodeRefreshOutput* nodeOutput = nil;
                for (NodeRefreshOutput* output in apiOutputs){
                    if ([item.commitment isEqualToString:output.commit]){
                        nodeOutput = output;
                    }
                }
                
                if (nodeOutput){
                    //should not be coinbase
                    if (item.is_coinbase && item.status == Unconfirmed){
                        
                    }
                    else if(!item.is_coinbase && item.status == Unconfirmed) {
                        VcashTxLog* tx = nil;
                        for (VcashTxLog* txlog in txs){
                            if (txlog.tx_id == item.tx_log_id){
                                tx = txlog;
                            }
                        }
                        if (tx){
                            tx.confirm_state = NetConfirmed;
                            tx.confirm_time = [[NSDate date] timeIntervalSince1970];
                            tx.status = TxFinalized;
                        }
                        item.height = nodeOutput.height;
                        item.status = Unspent;
                        
                        hasChange = YES;
                    }
                }
                else{
                    if (item.status == Locked || item.status == Unspent){
                        VcashTxLog* tx = nil;
                        for (VcashTxLog* txlog in txs){
                            if (txlog.confirm_state == LoalConfirmed){
                                for (NSString* commitStr in txlog.inputs){
                                    if ([commitStr isEqualToString:item.commitment]){
                                        tx = txlog;
                                    }
                                }
                            }
                            if (tx != nil){
                                break;
                            }
                        }
                        if (tx){
                            tx.confirm_state = NetConfirmed;
                            tx.confirm_time = [[NSDate date] timeIntervalSince1970];
                            tx.status = TxFinalized;
                        }
                        item.status = Spent;
                        hasChange = YES;
                    }
                }
            }
            if (hasChange){
                [[VcashDataManager shareInstance] saveTxDataArr:txs];
                [[VcashWallet shareInstance] syncOutputInfo];
            }
        }
        block?block(yesOrNO, nil):nil;
    }];
}

+(double)nanoToVcash:(int64_t)nano
{
    return (double)nano/VCASH_BASE;
}

+(int64_t)vcashToNano:(double)vcash{
    return (int64_t)(vcash*VCASH_BASE);
}

#pragma private
+(BOOL)checkWalletState{
    return [VcashWallet shareInstance]?YES:NO;
}

@end

