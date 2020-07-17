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
#import "JsonRpc.h"
#import "payment-proof-lib.h"

@interface BTCMnemonic (Words)
+(NSArray*) englishWordList;
@end

static NSDictionary* tokenInfoDic;
static NSMutableSet* addedToken;

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

+(BOOL)isValidSlatePackAddress:(NSString*)address {
    NSString* pubkey = [WalletWrapper getPubkeyFromProofAddress:address];
    return pubkey.length > 0;
}

+(NSString*)getPubkeyFromProofAddress:(NSString*)proofAddress {
    if (proofAddress.length != 65 && proofAddress.length != 64) {
        return nil;
    }
    const char* proofAddressStr = [proofAddress UTF8String];
    const char* pubkeyAddStr = slate_address_to_pubkey_address(proofAddressStr);
    NSString* pubkeyAddress = [NSString stringWithUTF8String:pubkeyAddStr];
    c_str_free(pubkeyAddStr);
    return pubkeyAddress;
}

+(NSString*)getProofAddressFromPublicKey:(NSString*)publicKey {
    if (publicKey.length != 64) {
        return nil;
    }
    
    bool isTestNet = false;
    #ifdef isInTestNet
        isTestNet = true;
    #endif
    
    const char* publicKeyStr = [publicKey UTF8String];
    const char* proofAddressStr = pubkey_address_to_slate_address(publicKeyStr, isTestNet);
    NSString* proofAddress = [NSString stringWithUTF8String:proofAddressStr];
    c_str_free(proofAddressStr);
    return proofAddress;
}

+(NSString*)getPaymentProofMessage:(NSString*)token_type amount:(int64_t)amount excess:(NSString*)excess andSenderPubkey:(NSString*)senderPubkey {
    NSMutableData* msgData = [NSMutableData new];
    [msgData appendData:BTCDataFromHex(token_type)];
    uint8_t buf[8];
    OSWriteBigInt64(buf, 0, amount);
    [msgData appendBytes:buf length:8];
    [msgData appendData:BTCDataFromHex(excess)];
    [msgData appendData:BTCDataFromHex(senderPubkey)];
    NSString* msg = BTCHexFromData(msgData);
    return msg;
}

+(NSString*)createPaymentProofSignature:(NSString*)token_type amount:(int64_t)amount excess:(NSString*)excess andSenderPubkey:(NSString*)senderPubkey andSecretKey:(NSString*)secKey{
    NSString* msg = [self getPaymentProofMessage:token_type amount:amount excess:excess andSenderPubkey:senderPubkey];
    const char* signatureStr = create_payment_proof_signature([msg UTF8String], [secKey UTF8String]);
    NSString* signature = [NSString stringWithUTF8String:signatureStr];
    c_str_free(signatureStr);
    return signature;
}

+(Boolean)verifyPaymentProof:(NSString*)token_type amount:(int64_t)amount excess:(NSString*)excess senderPubkey:(NSString*)senderPubkey verifyPubkey:(NSString*)verifyPubkey andSignature:(NSString*)signature {
    NSString* msg = [self getPaymentProofMessage:token_type amount:amount excess:excess andSenderPubkey:senderPubkey];
    bool yesOrNo = verify_payment_proof([msg UTF8String], [verifyPubkey UTF8String], [signature UTF8String]);
    return yesOrNo;
}

+(NSString*)exportPaymentProof:(VcashSlate*)slate {
    if (slate.payment_proof) {
        ExportPaymentInfo* proof = [ExportPaymentInfo new];
        proof.token_type = slate.token_type;
        proof.amount = [[NSNumber numberWithUnsignedLongLong:slate.amount] stringValue];
        NSData* excessData = [slate calculateExcess];

        proof.excess = BTCHexFromData(excessData);
        proof.recipient_address = [WalletWrapper getProofAddressFromPublicKey:slate.payment_proof.receiver_address];
        proof.recipient_sig = slate.payment_proof.receiver_signature;
        proof.sender_address = [VcashWallet shareInstance].userId;
        NSData* sec_key = [[VcashWallet shareInstance] getPaymentProofKey];
        NSString* sec_str = BTCHexFromData(sec_key);
        NSString* signature = [self createPaymentProofSignature:slate.token_type amount:slate.amount excess:proof.excess andSenderPubkey:slate.payment_proof.sender_address andSecretKey:sec_str];
        if (signature) {
            Boolean isValid = [self verifyPaymentProof:slate.token_type amount:slate.amount excess:proof.excess senderPubkey:slate.payment_proof.sender_address verifyPubkey:slate.payment_proof.sender_address andSignature:signature];
            if (isValid) {
                proof.sender_sig = signature;
                return [proof modelToJSONString];
            }
        }
    }
    
    return nil;
}

+(void)verifyPaymentProof:(NSString*)proofStr WithComplete:(RequestCompleteBlock)block;{
    ExportPaymentInfo* proof = [ExportPaymentInfo modelWithJSON:proofStr];
    if (proof) {
        NSString* senderAddr;
        if (proof.sender_address.length == 64) {
            senderAddr = proof.sender_address;
        } else if (proof.sender_address.length == 56) {
            senderAddr = [self getPubkeyFromProofAddress:proof.sender_address];
        } else {
            block?block(NO, @"Sender address format is invalid."):nil;
            return;
        }
        
        NSString* receiverAddr;
        if (proof.recipient_address.length == 64) {
            receiverAddr = proof.recipient_address;
        } else if (proof.recipient_address.length == 56) {
            receiverAddr = [self getPubkeyFromProofAddress:proof.recipient_address];
        } else {
            block?block(NO, @"Recipient address format is invalid."):nil;
            return;
        }
        
        if (proof.sender_sig.length != 128) {
            block?block(NO, @"Sender signature format is invalid."):nil;
            return;
        }
        
        if (proof.recipient_sig.length != 128) {
            block?block(NO, @"Recipient signature format is invalid."):nil;
            return;
        }
        
        Boolean isSenderSigValid = [self verifyPaymentProof:proof.token_type amount:[proof.amount unsignedLongLongValue] excess:proof.excess senderPubkey:senderAddr verifyPubkey:senderAddr andSignature:proof.sender_sig];
        if (!isSenderSigValid) {
            block?block(NO, @"Invalid sender signature"):nil;
            return;
        }
        Boolean isReceiverSigValid = [self verifyPaymentProof:proof.token_type amount:[proof.amount unsignedLongLongValue] excess:proof.excess senderPubkey:senderAddr verifyPubkey:receiverAddr andSignature:proof.recipient_sig];
        if (!isReceiverSigValid) {
            block?block(NO, @"Invalid recipient signature"):nil;
            return;
        }
        
        if (proof.token_type) {
            [[NodeApi shareInstance] getTokenKernel:proof.excess WithComplete:^(BOOL yesOrNo, id data) {
                if (yesOrNo) {
                    block?block(YES, @"Signature is valid"):nil;
                } else {
                    block?block(NO, @"Transaction not found on chain"):nil;
                }
            }];
        } else {
            [[NodeApi shareInstance] getKernel:proof.excess WithComplete:^(BOOL yesOrNo, id data) {
                if (yesOrNo) {
                    block?block(YES, @"Signature is valid"):nil;
                } else {
                    block?block(NO, @"Transaction not found on chain"):nil;
                }
            }];
        }
        
        return;
    }
    block?block(NO, @"Proof format is invalid."):nil;
    return;
}

+(VcashSlate*)parseSlateFromEncrypedSlatePackStr:(NSString*)slateStr {
    NSData* key = [[VcashWallet shareInstance] getPaymentProofKey];
    const char*  slate_bin_str = slate_from_slatepack_message(slateStr.UTF8String, BTCHexFromData(key).UTF8String);
    NSString* slateBin = [NSString stringWithUTF8String:slate_bin_str];
    c_str_free(slate_bin_str);
    
    VcashSlate* slate = [self slateFromHex:slateBin];
    
    const char*  sender_addr_str = sender_address_from_slatepack_message(slateStr.UTF8String, BTCHexFromData(key).UTF8String);
    NSString* slateAddress = [NSString stringWithUTF8String:sender_addr_str];
    c_str_free(sender_addr_str);
    
    slate.partnerAddress = slateAddress;
    
    VcashContext* context = [[VcashDataManager shareInstance] getContextBySlateId:slate.uuid];
    if (context){
        slate.amount = context.amount;
        slate.fee = context.fee;
    }
    
    return slate;
}

+(VcashSlate*)slateFromHex:(NSString*)slateStr {
    VcashSlate* slate = [VcashSlate parseSlateFromData:BTCDataFromHex(slateStr)];
    
    return slate;
}

+(NSString*)hexForSlate:(VcashSlate*)slate {
    NSData* slate_bin = [slate selializeAsData];
    NSString* slateBinStr = BTCHexFromData(slate_bin);
    
    return slateBinStr;
}

+(NSString*)encryptSlateForParter:(VcashSlate*)slate {
    NSString* slateBinStr = [self hexForSlate:slate];
    const char*  slate_bin_str = create_slatepack_message(slateBinStr.UTF8String, slate.partnerAddress.UTF8String, [VcashWallet shareInstance].userId.UTF8String);
    NSString* slateBin = [NSString stringWithUTF8String:slate_bin_str];
    c_str_free(slate_bin_str);
    
    return slateBin;
}

+(WalletBalanceInfo*)getWalletBalanceInfo{
    return [[VcashWallet shareInstance] getWalletBalanceInfo];
}

+(NSArray*)getBalancedToken{
    return [VcashWallet shareInstance].token_outputs_dic.allKeys;
}

+(WalletBalanceInfo*)getWalletTokenBalanceInfo:(NSString*)tokenType{
    return [[VcashWallet shareInstance] getWalletTokenBalanceInfo:tokenType];
}

+(uint64_t)getCurChainHeight{
    return [VcashWallet shareInstance].curChainHeight;
}

+(void)checkWalletUtxoFromIndex:(uint64_t)startIndex WithComplete:(RequestCompleteBlock)block{
    [[NodeApi shareInstance] getOutputsByPmmrIndex:startIndex WithComplete:^(BOOL yesOrNo, id result) {
        if (yesOrNo){
            if ([result isKindOfClass:[NSArray class]]){
                NSMutableArray* txArr = [NSMutableArray new];
                for (VcashOutput* item in (NSArray*)result){
                    VcashTxLog* tx = [VcashTxLog new];
                    tx.tx_id = [[VcashWallet shareInstance] getNextLogId];
                    tx.create_time = [[NSDate date] timeIntervalSince1970];
                    tx.confirm_height = item.height;
                    tx.confirm_state = NetConfirmed;
                    tx.amount_credited = item.value;
                    tx.tx_type = item.is_coinbase?ConfirmedCoinbaseOrTokenIssue:TxReceived;
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

+(void)checkWalletTokenUtxoFromIndex:(uint64_t)startIndex WithComplete:(RequestCompleteBlock)block{
    [[NodeApi shareInstance] getTokenOutputsByPmmrIndex:startIndex WithComplete:^(BOOL yesOrNo, id result) {
        if (yesOrNo){
            if ([result isKindOfClass:[NSArray class]]){
                NSMutableArray* txArr = [NSMutableArray new];
                for (VcashTokenOutput* item in (NSArray*)result){
                    VcashTokenTxLog* tx = [VcashTokenTxLog new];
                    tx.tx_id = [[VcashWallet shareInstance] getNextLogId];
                    tx.create_time = [[NSDate date] timeIntervalSince1970];
                    tx.confirm_height = item.height;
                    tx.confirm_state = NetConfirmed;
                    tx.token_amount_credited = item.value;
                    tx.tx_type = item.is_token_issue?ConfirmedCoinbaseOrTokenIssue:TxReceived;
                    tx.token_type = item.token_type;
                    
                    item.tx_log_id = tx.tx_id;
                    
                    [txArr addObject:tx];
                }
                [[VcashWallet shareInstance] setChainTokenOutputs:(NSArray*)result];
                [[VcashDataManager shareInstance] saveTokenTxDataArr:txArr byReplace:YES];
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

+(void)createSendTransaction:(NSString*)tokenType andAmount:(uint64_t)amount andProofAddress:(NSString*)proofAddress withComplete:(RequestCompleteBlock)block {
    PaymentInfo* info;
    if ([WalletWrapper isValidSlatePackAddress:proofAddress]){
        NSString* receiverAddr = [self getPubkeyFromProofAddress:proofAddress];
        info = [PaymentInfo new];
        info.sender_address = [self getPubkeyFromProofAddress:[VcashWallet shareInstance].userId];
        info.receiver_address = receiverAddr;
    }
    
    if (tokenType) {
        return [[VcashWallet shareInstance] sendTokenTransaction:tokenType andAmount:amount withComplete:^(BOOL yesOrNO, id data) {
            if (yesOrNO) {
                VcashSlate* slate = (VcashSlate*)data;
                slate.partnerAddress = proofAddress;
                slate.payment_proof = info;
            }
            block?block(yesOrNO, data):nil;
        }];
    } else {
        return [[VcashWallet shareInstance] sendTransaction:amount andFee:0 withComplete:^(BOOL yesOrNO, id data) {
            if (yesOrNO) {
                VcashSlate* slate = (VcashSlate*)data;
                slate.partnerAddress = proofAddress;
                slate.payment_proof = info;
            }
            block?block(yesOrNO, data):nil;
        }];
    }
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
        [[VcashWallet shareInstance] reloadTokenOutputInfo];
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
            NSString* postUrl = [NSString stringWithFormat:@"%@/v2/foreign", url];
            NSString* slate_str = [slate modelToJSONObject];
            JsonRpc* rpc = [[JsonRpc alloc] initWithMethod:@"receive_tx" andParamArr:[NSArray arrayWithObjects:slate_str, [NSNull null], [NSNull null], nil]];
            NSString* param = [rpc modelToJSONObject];
            [sessionManager POST:postUrl parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                NSString*resStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                JsonRpcRes* res = [JsonRpcRes modelWithJSON:resStr];
                if (res.error){
                    DDLogWarn(@"sendTransaction post to %@ fail:%@!", postUrl, res.error);
                    rollbackBlock();
                    block?block(NO, data):nil;
                } else {
                    DDLogWarn(@"sendTransaction post to %@ suc!", postUrl);
                    NSString* slateStr = res.result[@"Ok"];
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
                }
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
        [[VcashWallet shareInstance] reloadTokenOutputInfo];
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
        [[VcashWallet shareInstance] reloadTokenOutputInfo];
    };
    
    [self sendTx:slate withComplete:^(BOOL yesOrNO, id _Nullable data) {
        if (yesOrNO){
            DDLogWarn(@"sendTransaction by file suc");
            [[VcashDataManager shareInstance] commitDatabaseTransaction];
            NSString* str = [WalletWrapper encryptSlateForParter:slate];
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
    slate.lockTokenOutputsFn?slate.lockTokenOutputsFn():nil;
    slate.createNewOutputsFn?slate.createNewOutputsFn():nil;
    slate.createNewTokenOutputsFn?slate.createNewTokenOutputsFn():nil;
    
    //save txLog
    NSString* slate_str = [WalletWrapper hexForSlate:slate];
    if (slate.txLog) {
        slate.txLog.status = TxDefaultStatus;
        slate.txLog.signed_slate_msg = slate_str;
        int ret = [[VcashDataManager shareInstance] saveTx:slate.txLog];
        if (!ret){
            block?block(NO, @"Db error:saveTx failed"):nil;
            return;
        }
    } else {
        slate.tokenTxLog.status = TxDefaultStatus;
        slate.tokenTxLog.signed_slate_msg = slate_str;
        int ret = [[VcashDataManager shareInstance] saveTx:slate.tokenTxLog];
        if (!ret){
            block?block(NO, @"Db error:saveTokenTx failed"):nil;
            return;
        }
    }

    //save output status
    [[VcashWallet shareInstance] syncOutputInfo];
    [[VcashWallet shareInstance] syncTokenOutputInfo];
    
    //save context
    int ret = [[VcashDataManager shareInstance] saveContext:slate.context];
    if (!ret){
        block?block(NO, @"Db error:save context failed"):nil;
        return;
    }
    
    block?block(YES, nil):nil;
    return;
}

+(void)isValidSlateConentForReceive:(NSString*)slateStr withComplete:(RequestCompleteBlock)block{
    VcashSlate* slate = [WalletWrapper parseSlateFromEncrypedSlatePackStr:slateStr];
    if (!slate || ![slate isValidForReceive]){
        block?block(NO, @"Wrong Data Format"):nil;
        return;
    }
    
    BaseVcashTxLog* txLog = [[VcashDataManager shareInstance] getTxBySlateId:slate.uuid];
    if (txLog){
        block?block(NO, @"Duplicate Tx"):nil;
        return;
    }
    
    block?block(YES, slate):nil;
}

+(void)isValidSlateConentForFinalize:(NSString*)slateStr withComplete:(RequestCompleteBlock)block{
    @try {
        VcashSlate* slate = [VcashSlate modelWithJSON:slateStr];
        if (!slate || ![slate isValidForFinalize]){
            block?block(NO, @"Wrong Data Format"):nil;
            return;
        }
        
        BaseVcashTxLog* txLog = [[VcashDataManager shareInstance] getTxBySlateId:slate.uuid];
        if (!txLog){
            block?block(NO, @"Tx missed"):nil;
            return;
        }
        
        block?block(YES, slate):nil;
    }
    @catch (NSException *exception) {
        block?block(NO, @"Wrong Data Format"):nil;
    }
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
    
    if (slate.ttl_cutoff_height > 0 && slate.ttl_cutoff_height <= [VcashWallet shareInstance].curChainHeight ) {
        DDLogError(@"Transaction Expired!");
        block?block(NO, @"Transaction Expired!"):nil;
        return;
    }
    
    BOOL ret = [[VcashDataManager shareInstance] beginDatabaseTransaction];
    if (!ret){
        DDLogError(@"beginDatabaseTransaction failed");
        block?block(NO, @"Db error"):nil;
        return;
    }
    
    dispatch_block_t rollbackBlock = ^{
        [[VcashDataManager shareInstance] rollbackDataTransaction];
        [[VcashWallet shareInstance] reloadOutputInfo];
        [[VcashWallet shareInstance] reloadTokenOutputInfo];
    };
    
    ret = [[VcashWallet shareInstance] receiveTransaction:slate];
    if (!ret){
        rollbackBlock();
        DDLogError(@"VcashWallet receiveTransaction failed");
        block?block(NO, nil):nil;
        return;
    }
    
    if (slate.payment_proof) {
        if (slate.payment_proof.receiver_address.length != 64 ||
            slate.payment_proof.sender_address.length != 64) {
            rollbackBlock();
            DDLogError(@"Tx payment proof address is invalid!");
            block?block(NO, @"Tx payment proof address is invalid!"):nil;
            return;
        }
        
        NSString* selfAddress = [self getPubkeyFromProofAddress:[VcashWallet shareInstance].userId];
        if (![slate.payment_proof.receiver_address isEqualToString:selfAddress]) {
            rollbackBlock();
            DDLogError(@"Tx is not for me");
            block?block(NO, @"Tx is not for me"):nil;
            return;
        }
        
        NSData* excess = [slate calculateExcess];
        NSData* sec_key = [[VcashWallet shareInstance] getPaymentProofKey];
        NSString* sec_str = BTCHexFromData(sec_key);
        NSString* signature = [self createPaymentProofSignature:slate.token_type amount:slate.amount excess:BTCHexFromData(excess) andSenderPubkey:slate.payment_proof.sender_address andSecretKey:sec_str];
        if (!signature) {
            rollbackBlock();
            DDLogError(@"Create Tx payment proof failed");
            block?block(NO, @"Create Tx payment proof failed"):nil;
            return;
        }
        Boolean isValid = [self verifyPaymentProof:slate.token_type amount:slate.amount excess:BTCHexFromData(excess) senderPubkey:slate.payment_proof.sender_address verifyPubkey:selfAddress andSignature:signature];
        if (!isValid) {
            rollbackBlock();
            DDLogError(@"Create Tx payment proof signature failed");
            block?block(NO, nil):nil;
            return;
        }
        slate.payment_proof.receiver_signature = signature;
    }
    
    // Can remove amount and fee now
    // as well as sender's sig data
    slate.amount = 0;
    slate.fee = 0;
    [slate removeOtherSigdata];
    slate.state = Standard2;
    
    NSString* slateStr = [WalletWrapper encryptSlateForParter:slate];
    if (slate.token_type) {
        slate.createNewTokenOutputsFn?slate.createNewTokenOutputsFn():nil;
        //save tokentxLog
        slate.tokenTxLog.parter_id = serverTx.sender_id;
        slate.tokenTxLog.status = TxReceiverd;
        slate.tokenTxLog.signed_slate_msg = slateStr;
        ret = [[VcashDataManager shareInstance] saveTx:slate.tokenTxLog];
        if (!ret){
            rollbackBlock();
            DDLogError(@"VcashDataManager saveTokenTx failed");
            block?block(NO, @"Db error"):nil;
            return;
        }
        
        //save output status
        [[VcashWallet shareInstance] syncTokenOutputInfo];
    } else {
        slate.createNewOutputsFn?slate.createNewOutputsFn():nil;
        //save txLog
        slate.txLog.parter_id = serverTx.sender_id;
        slate.txLog.status = TxReceiverd;
        slate.txLog.signed_slate_msg = slateStr;
        ret = [[VcashDataManager shareInstance] saveTx:slate.txLog];
        if (!ret){
            rollbackBlock();
            DDLogError(@"VcashDataManager saveTx failed");
            block?block(NO, @"Db error"):nil;
            return;
        }
        
        //save output status
        [[VcashWallet shareInstance] syncOutputInfo];
    }
    
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
            tx.slate  = [WalletWrapper encryptSlateForParter:tx.slateObj];
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
    BaseVcashTxLog *txLog = [[VcashDataManager shareInstance] getTxBySlateId:slate.uuid];
    if (!txLog || !txLog.signed_slate_msg) {
        DDLogError(@"--------database record is broke, cannot find tx record");
        block?block(NO, @""):nil;
        return;
    }
    
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
    
    //check payment proof
    VcashSlate* origSlate = [WalletWrapper slateFromHex:txLog.signed_slate_msg];
    if (origSlate.payment_proof) {
        if (!slate.payment_proof) {
            DDLogError(@"--------Expected Payment Proof for this Transaction is not present");
            block?block(NO, @"Expected Payment Proof for this Transaction is not present"):nil;
            return;
        }
        if (![origSlate.payment_proof.receiver_address isEqualToString:slate.payment_proof.receiver_address] ||
            ![origSlate.payment_proof.sender_address isEqualToString:slate.payment_proof.sender_address]){
            DDLogError(@"--------Payment Proof address does not match original Payment Proof address");
            block?block(NO, @"Payment Proof address does not match original Payment Proof address"):nil;
            return;
        }
        NSData* excess = [slate calculateExcess];
        Boolean isValid = [self verifyPaymentProof:slate.token_type amount:slate.amount excess:BTCHexFromData(excess) senderPubkey:slate.payment_proof.sender_address verifyPubkey:slate.payment_proof.receiver_address andSignature:slate.payment_proof.receiver_signature];
        if (!isValid) {
            DDLogError(@"--------Recipient did not provide requested proof signature");
            block?block(NO, @"Recipient did not provide requested proof signature"):nil;
            return;
        }
    }
    
    [slate.tx sortTx];
    NSData* txPayload = [slate.tx computePayloadForHash:NO];
    [[NodeApi shareInstance] postTx:BTCHexFromData(txPayload) WithComplete:^(BOOL yesOrNo, id _Nullable data) {
//    NSString* txStr = [slate.tx modelToJSONObject];
//    [[NodeApi shareInstance] postTx:txStr WithComplete:^(BOOL yesOrNo, id _Nullable data) {
        if (yesOrNo){
            block?block(YES, nil):nil;
            
            if (txLog){
                txLog.confirm_state = LoalConfirmed;
                txLog.status = TxFinalized;
                txLog.signed_slate_msg = [self hexForSlate:slate];
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
    BaseVcashTxLog *txLog =  [self getTxByTxid:tx_id];
    if ([txLog isCanBeCanneled] || txLog == nil){
        [txLog cancelTxlog];
        [[VcashDataManager shareInstance] saveTx:txLog];
        
        //if (txLog.parter_id){
            [[ServerApi shareInstance] cancelTransaction:tx_id WithComplete:^(BOOL yesOrNo, id _Nullable data) {
                if (!yesOrNo){
                    DDLogError(@"cancel tx to Server failed");
                }
            }];
        //}
        
        return YES;
    }
    
    return NO;
}

+(NSArray*)getTransationArr{
    return [[VcashDataManager shareInstance] getTxData];
}

+(NSArray*)getTokenTxArr:(NSString*)tokenType{
    return [[VcashDataManager shareInstance] getTokenTxData:tokenType];
}

+(BaseVcashTxLog*)getTxByTxid:(NSString*)txid{
    return [[VcashDataManager shareInstance] getTxBySlateId:txid];
}

+(Boolean)deleteTxByTxid:(NSString*)txid{
    return  [[VcashDataManager shareInstance] deleteTxBySlateId:txid];
}

+(Boolean)deleteTokenTxByTxid:(NSString*)txid{
    return  [[VcashDataManager shareInstance] deleteTokenTxBySlateId:txid];
}

+(NSArray*)getFileReceiveTxArr{
    NSArray* txArr = [self getTransationArr];
    NSMutableArray* retArr = [NSMutableArray new];
    for (VcashTxLog* item in txArr){
        if (item.tx_type == TxReceived && !item.parter_id && item.signed_slate_msg){
            [retArr addObject:item];
        }
    }
    NSArray* tokenTxArr = [self getTokenTxArr:nil];
    for (VcashTokenTxLog* item in tokenTxArr) {
        if (item.tx_type == TxReceived && !item.parter_id && item.signed_slate_msg){
            [retArr addObject:item];
        }
    }
    
    return retArr;
}

+(void)updateTxStatus {
    NSArray* txArr = [[VcashDataManager shareInstance] getTxData];
    for (VcashTxLog* tx in txArr) {
        [WalletWrapper checkSingleTxStatus:tx];
    }
    NSArray* tokenTxArr = [[VcashDataManager shareInstance] getTokenTxData:nil];
    for (VcashTokenTxLog* tx in tokenTxArr) {
        [WalletWrapper checkSingleTxStatus:tx];
    }
}

+(void)checkSingleTxStatus:(BaseVcashTxLog*)tx {
    if (![tx isCanBeAutoCanneled]){
        return;
    }
    if (tx.signed_slate_msg) {
        @try {
            VcashSlate* slate = [VcashSlate modelWithJSON:tx.signed_slate_msg];
            if (slate &&
                slate.ttl_cutoff_height > 0 &&
                slate.ttl_cutoff_height <= [VcashWallet shareInstance].curChainHeight ) {
                [tx cancelTxlog];
                [[VcashDataManager shareInstance] saveTx:tx];
            }
        }
        @catch (NSException *exception) {
            
        }
    }
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
            NSArray* walletOutputs = [VcashWallet shareInstance].outputs;
            for (VcashOutput* item in walletOutputs){
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
                            tx.confirm_height = nodeOutput.height;
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
                            [[NodeApi shareInstance] getOutputsByCommitArr:tx.outputs WithComplete:^(BOOL yesOrNO, id data) {
                                if (yesOrNO){
                                    NSArray* apiOutputs = data;
                                    NodeRefreshOutput* output = apiOutputs.firstObject;
                                    tx.confirm_height = output.height;
                                    [[VcashDataManager shareInstance] saveTx:tx];
                                }
                            }];
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

+(void)updateTokenOutputStatusWithComplete:(RequestCompleteBlock)block{
    [self updateTokenOutputStatusForToken:[VcashWallet shareInstance].token_outputs_dic.allKeys.firstObject WithComplete:block];
}

+(void)updateTokenOutputStatusForToken:(NSString*)token_type WithComplete:(RequestCompleteBlock)block{
    if (token_type == nil) {
        block?block(YES, nil):nil;
        return;
    }

    [self implUpdateTokenOutputStatusForToken:token_type WithComplete:^(BOOL yesOrNo, id data) {
        if (yesOrNo){
            NSArray* allToken = [VcashWallet shareInstance].token_outputs_dic.allKeys;
            NSUInteger index = [allToken indexOfObject:token_type];
            if (index+1 >= [allToken count]) {
                block?block(YES, nil):nil;
                return;
            }
            NSString* next_token_type = [allToken objectAtIndex:index+1];
            [self updateTokenOutputStatusForToken:next_token_type WithComplete:block];
        }
        else {
            block?block(NO, nil):nil;
            return;
        }
    }];

}

+(void)implUpdateTokenOutputStatusForToken:(NSString*)token_type WithComplete:(RequestCompleteBlock)block{
    NSArray* token_arr = [VcashWallet shareInstance].token_outputs_dic[token_type];
    NSMutableArray* strArr = [NSMutableArray new];
    for (VcashTokenOutput* item in token_arr){
        [strArr addObject:item.commitment];
    }
    
    if (strArr.count == 0){
        DDLogWarn(@"TokenType:%@ has no token output", token_type);
        block?block(YES, nil):nil;
        return;
    }
    
    [[NodeApi shareInstance] getTokenOutputsForToken:token_type WithCommitArr:strArr WithComplete:^(BOOL yesOrNO, id data) {
        if (yesOrNO){
            NSArray* apiOutputs = data;
            NSArray* txs = [self getTokenTxArr:token_type];
            BOOL hasChange = NO;
            for (VcashTokenOutput* item in token_arr){
                NodeRefreshTokenOutput* nodeOutput = nil;
                for (NodeRefreshTokenOutput* output in apiOutputs){
                    if ([item.commitment isEqualToString:output.commit]){
                        nodeOutput = output;
                    }
                }
                
                if (nodeOutput){
                    //should not be issue token
                    if (item.is_token_issue && item.status == Unconfirmed){
                        
                    }
                    else if(!item.is_token_issue && item.status == Unconfirmed) {
                        VcashTokenTxLog* tx = nil;
                        for (VcashTokenTxLog* txlog in txs){
                            if (txlog.tx_id == item.tx_log_id){
                                tx = txlog;
                            }
                        }
                        if (tx){
                            tx.confirm_state = NetConfirmed;
                            tx.confirm_time = [[NSDate date] timeIntervalSince1970];
                            tx.confirm_height = nodeOutput.height;
                            tx.status = TxFinalized;
                        }
                        item.height = nodeOutput.height;
                        item.status = Unspent;
                        
                        hasChange = YES;
                    }
                }
                else{
                    if (item.status == Locked || item.status == Unspent){
                        VcashTokenTxLog* tx = nil;
                        for (VcashTokenTxLog* txlog in txs){
                            if (txlog.confirm_state == LoalConfirmed){
                                for (NSString* commitStr in txlog.token_inputs){
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
                            [[NodeApi shareInstance] getOutputsByCommitArr:tx.outputs WithComplete:^(BOOL yesOrNO, id data) {
                                if (yesOrNO){
                                    NSArray* apiOutputs = data;
                                    NodeRefreshOutput* output = apiOutputs.firstObject;
                                    tx.confirm_height = output.height;
                                    [[VcashDataManager shareInstance] saveTx:tx];
                                }
                            }];
                        }
                        item.status = Spent;
                        hasChange = YES;
                    }
                }
            }
            if (hasChange){
                [[VcashDataManager shareInstance] saveTokenTxDataArr:txs byReplace:NO];
                [[VcashWallet shareInstance] syncOutputInfo];
                [[VcashWallet shareInstance] syncTokenOutputInfo];
            }
        }
        block?block(yesOrNO, nil):nil;
    }];
}

+(void)initTokenInfos {
    if (!tokenInfoDic) {
        [self readTokenInfoFromFile];
        [self readAddedTokenFromFile];
        [self updateTokenInfos];
    }
}

+(void)updateTokenInfos {
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    sessionManager.requestSerializer.timeoutInterval = 20.0f;
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    sessionManager.securityPolicy.allowInvalidCertificates = YES;
    sessionManager.securityPolicy.validatesDomainName = NO;
    NSString* url = @"https://s.vcashwallet.app/token_static/VCashTokenInfo.json";
    
    [sessionManager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString*resStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSArray* tokenInfos = [NSArray modelArrayWithClass:[VcashTokenInfo class] json:resStr];
        NSMutableDictionary* dic = [NSMutableDictionary new];
        for (VcashTokenInfo* item in tokenInfos) {
            [dic setObject:item forKey:item.TokenId];
        }
        if ([dic count] > 0) {
            tokenInfoDic = dic;
        }
        [self writeTokenInfoToFile];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"fetch Tokeninfos failed...");
    }];
}

+(void)writeTokenInfoToFile{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *path = [self tokenInfoSavePath];
        [NSKeyedArchiver archiveRootObject:tokenInfoDic toFile:path];
    });
}

+(void)readTokenInfoFromFile{
    tokenInfoDic = [NSKeyedUnarchiver unarchiveObjectWithFile:[self tokenInfoSavePath]];
}

+(NSString *)tokenInfoSavePath{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"tokeninfo"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [url setResourceValue: [NSNumber numberWithBool: YES]
                   forKey: NSURLIsExcludedFromBackupKey error: &error];
    return path;
}

+(void)writeAddedTokenToFile{
    NSString *path = [self addedTokenSavePath];
    NSArray* tmp = [addedToken allObjects];
    [NSKeyedArchiver archiveRootObject:tmp toFile:path];
}

+(void)readAddedTokenFromFile{
    NSArray* tmp = [NSKeyedUnarchiver unarchiveObjectWithFile:[self addedTokenSavePath]];
    addedToken = [NSMutableSet new];
    [addedToken addObjectsFromArray:tmp];
}

+(NSString *)addedTokenSavePath{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"addedtoken"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [url setResourceValue: [NSNumber numberWithBool: YES]
                   forKey: NSURLIsExcludedFromBackupKey error: &error];
    return path;
}

+(NSArray*)getAllTokens {
    return [tokenInfoDic allKeys];
}

+(VcashTokenInfo*)getTokenInfo:(NSString*)tokenId {
    VcashTokenInfo* info = [tokenInfoDic objectForKey:tokenId];
    if (!info && tokenId.length == 64){
        info = [VcashTokenInfo new];
        info.TokenId = tokenId;
        info.Name = [tokenId substringToIndex:8];
        info.FullName = @"--";
    }
    
    return info;
}

+(NSArray*)getAddedTokens {
    return [addedToken allObjects];;
}

+(void)addAddedToken:(NSString*)tokenType {
    if (![addedToken containsObject:tokenType]) {
        [addedToken addObject:tokenType];
        [self writeAddedTokenToFile];
    }

}

+(void)deleteAddedToken:(NSString*)tokenType {
    if ([addedToken containsObject:tokenType]) {
        [addedToken removeObject:tokenType];
        [self writeAddedTokenToFile];
    }
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

