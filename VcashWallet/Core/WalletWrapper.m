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

+(void)checkWalletUtxoWithComplete:(RequestCompleteBlock)block{
    NSMutableArray* arr = [NSMutableArray new];
    [[NodeApi shareInstance] getOutputsByPmmrIndex:0 retArr:arr WithComplete:^(BOOL yesOrNo, id result) {
        if (yesOrNo){
            [[VcashWallet shareInstance] setChainOutputs:(NSArray*)result];
            NSMutableArray* txArr = [NSMutableArray new];
            for (VcashOutput* item in (NSArray*)result){
                VcashTxLog* tx = [VcashTxLog new];
                tx.tx_id = [[VcashWallet shareInstance] getNextLogId];
                tx.create_time = [[NSDate date] timeIntervalSince1970];
                tx.is_confirmed = YES;
                tx.amount_credited = item.value;
                tx.tx_type = item.is_coinbase?ConfirmedCoinbase:TxReceived;
                item.tx_log_id = tx.tx_id;
                
                [txArr addObject:tx];
            }
            [[VcashDataManager shareInstance] saveTxDataArr:txArr];
            block?block(YES, txArr):nil;
        }
        else{
            block?block(NO, result):nil;
        }
    }];
}

+(VcashSlate*)createSendTransaction:(NSString*)targetUserId amount:(uint64_t)amount fee:(uint64_t)fee withComplete:(RequestCompleteBlock)block{
    return [[VcashWallet shareInstance] sendTransaction:amount andFee:fee withComplete:^(BOOL yesOrNO, id data) {
        block?block(yesOrNO, data):nil;
    }];

}

+(BOOL)sendTransaction:(VcashSlate*)slate forUser:(NSString*)user{
    BOOL ret = [[VcashDataManager shareInstance] beginDatabaseTransaction];
    if (!ret){
        DDLogError(@"beginDatabaseTransaction failed");
        return NO;
    }
    dispatch_block_t rollbackBlock = ^{
        [[VcashDataManager shareInstance] rollbackDataTransaction];
        [[VcashWallet shareInstance] reloadOutputInfo];
    };
    slate.lockOutputsFn?slate.lockOutputsFn():nil;
    slate.createNewOutputsFn?slate.createNewOutputsFn():nil;
    //save txLog
    ret = [[VcashDataManager shareInstance] saveAppendTx:slate.txLog];
    if (!ret){
        rollbackBlock();
        return NO;
    }
    //save context
    ret = [[VcashDataManager shareInstance] saveContext:slate.context];
    if (!ret){
        rollbackBlock();
        return NO;
    }
    
    ServerTransaction* server_tx = [ServerTransaction new];
    server_tx.sender_id = [VcashWallet shareInstance].userId;
    server_tx.receiver_id = user;
    server_tx.slate = [slate modelToJSONString];
    [[ServerApi shareInstance] sendTransaction:server_tx WithComplete:^(BOOL yesOrNO, id _Nullable data) {
        if (yesOrNO){
            DDLogInfo(@"-----send sendTransaction suc");
            [[VcashDataManager shareInstance] commitDatabaseTransaction];
        }
        else{
            DDLogError(@"-----send sendTransaction to server failed! roll back database");
            rollbackBlock();
        }
    }];
    
    return YES;
}

+(BOOL)receiveTransaction:(ServerTransaction*)tx{
    BOOL ret = [[VcashWallet shareInstance] receiveTransaction:tx.slateObj];
    if (!ret){
        DDLogError(@"VcashWallet receiveTransaction failed");
        return NO;
    }
    
    ret = [[VcashDataManager shareInstance] beginDatabaseTransaction];
    if (!ret){
        DDLogError(@"beginDatabaseTransaction failed");
        return NO;
    }
    dispatch_block_t rollbackBlock = ^{
        [[VcashDataManager shareInstance] rollbackDataTransaction];
        [[VcashWallet shareInstance] reloadOutputInfo];
    };
    
    tx.slateObj.createNewOutputsFn?tx.slateObj.createNewOutputsFn():nil;
    //save txLog
    ret = [[VcashDataManager shareInstance] saveAppendTx:tx.slateObj.txLog];
    if (!ret){
        rollbackBlock();
        DDLogError(@"VcashDataManager saveAppendTx failed");
        return NO;
    }
    
    tx.slate  = [tx.slateObj modelToJSONString];
    tx.send_type = 1;
    [[ServerApi shareInstance] receiveTransaction:tx WithComplete:^(BOOL yesOrNO, id _Nullable data) {
        if (yesOrNO){
            DDLogInfo(@"-----send receiveTransaction suc");
            [[VcashDataManager shareInstance] commitDatabaseTransaction];
        }
        else{
            DDLogError(@"-----send receiveTransaction to server failed! roll back database");
            rollbackBlock();
        }
    }];
    
    return YES;
}

+(BOOL)finalizeTransaction:(ServerTransaction*)tx{
    VcashContext* context = [[VcashDataManager shareInstance] getContextBySlateId:tx.slateObj.uuid];
    tx.slateObj.context = context;
    if (![[VcashWallet shareInstance] finalizeTransaction:tx.slateObj]){
        DDLogError(@"--------finalizeTransaction failed");
        return NO;
    }
    
    NSData* txPayload = [tx.slateObj.tx computePayloadForHash:NO];
    [[NodeApi shareInstance] postTx:BTCHexFromData(txPayload) WithComplete:^(BOOL yesOrNo, id _Nullable data) {
        if (yesOrNo){
            tx.slate  = [tx.slateObj modelToJSONString];
            tx.send_type = 2;
            [[ServerApi shareInstance] filanizeTransaction:tx];
        }
    }];
    
    return YES;
}

+(NSArray*)getTransationArr{
    return [[VcashDataManager shareInstance] getTxData];
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
                            tx.is_confirmed = YES;
                            tx.confirm_time = [[NSDate date] timeIntervalSince1970];
                        }
                        item.height = nodeOutput.height;
                        item.status = Unspent;
                        
                        hasChange = YES;
                    }
                }
                else{
                    if (item.status == Locked || item.status == Unspent){
                        item.status = Spent;
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

