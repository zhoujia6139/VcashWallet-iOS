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
    //[[BTCWallet shareInstance] clearWallet];
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
            DDLogInfo(@"-----send suc");
            [[VcashDataManager shareInstance] commitDatabaseTransaction];
        }
        else{
            DDLogError(@"-----send to server failed! roll back database");
            rollbackBlock();
        }
    }];
    
    return YES;
}

+(BOOL)receiveTransaction:(VcashSlate*)slate{
    BOOL ret = [[VcashWallet shareInstance] receiveTransaction:slate];
    if (!ret){
        DDLogError(@"VcashWallet receiveTransaction failed");
        return NO;
    }
    slate.createNewOutputsFn?slate.createNewOutputsFn():nil;
    //save txLog
    ret = [[VcashDataManager shareInstance] saveAppendTx:slate.txLog];
    if (!ret){
        DDLogError(@"VcashDataManager saveAppendTx failed");
        return NO;
    }
    return YES;
}

+(BOOL)finalizeTransaction:(VcashSlate*)slate{
    VcashContext* context = [[VcashDataManager shareInstance] getContextBySlateId:slate.uuid];
    slate.context = context;
    if (![[VcashWallet shareInstance] finalizeTransaction:slate]){
        DDLogError(@"--------finalizeTransaction failed");
        return NO;
    }
    
    NSData* txPayload = [slate.tx computePayloadForHash:NO];
    [[NodeApi shareInstance] postTx:BTCHexFromData(txPayload)];
    return YES;
}

+(NSArray*)getTransationArr{
    return [[VcashDataManager shareInstance] getTxData];
}

+(void)updateOutputStatus{
    NSMutableArray* strArr = [NSMutableArray new];
    for (VcashOutput* item in [VcashWallet shareInstance].outputs){
        [strArr addObject:item.commitment];
    }
    [[NodeApi shareInstance] getOutputsByCommitArr:strArr WithComplete:^(BOOL yesOrNO, id data) {
        if (yesOrNO){
            NSArray* apiOutputs = data;
            for (VcashOutput* item in [VcashWallet shareInstance].outputs){
                NodeOutput* nodeOutput = nil;
                for (NodeOutput* output in apiOutputs){
                    if ([item.commitment isEqualToString:output.commit]){
                        nodeOutput = output;
                    }
                }
                
                if (nodeOutput){
                    //should not be coinbase
                    if (item.is_coinbase && item.status == Unconfirmed){
                        
                    }
                    else if(!item.is_coinbase && item.status == Unconfirmed) {
                        NSArray* txs = [self getTransationArr];
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
                        item.height = nodeOutput.block_height;
                        item.status = Unspent;
                    }
                }
                else{
                    item.status = Spent;
                }
            }

        }
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

