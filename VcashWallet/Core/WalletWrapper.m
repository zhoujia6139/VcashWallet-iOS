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
                tx.create_time = [[NSDate date] timeIntervalSince1970];
                tx.is_confirmed = YES;
                tx.amount_credited = item.value;
                tx.tx_type = item.is_coinbase?ConfirmedCoinbase:TxReceived;
                
                [txArr addObject:tx];
            }
            [[VcashDataManager shareInstance] saveTxData:txArr];
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

+(void)sendTransaction:(VcashSlate*)slate{
    
}

+(VcashSlate*)receiveTransaction:(VcashSlate*)slate{
    return [[VcashWallet shareInstance] receiveTransaction:slate];
}

+(BOOL)finalizeTransaction:(VcashSlate*)slate{
    return [[VcashWallet shareInstance] finalizeTransaction:slate];
}

+(NSArray*)getTransationArr{
    return [[VcashDataManager shareInstance] getTxData];
}

+(double)nanoToVcash:(int64_t)nano
{
    return (double)nano/VCASH_BASE;
}

#pragma private
+(BOOL)checkWalletState{
    return [VcashWallet shareInstance]?YES:NO;
}

@end

