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
#import "VcashWallet.h"
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

+(void)checkWalletUtxoWithComplete:(RequestCompleteBlock)block{
    NSMutableArray* arr = [NSMutableArray new];
    [NodeApi getOutputsByPmmrIndex:0 retArr:arr WithComplete:^(BOOL yesOrNo, id result) {
        if (yesOrNo){
            [VcashWallet shareInstance].outputs = (NSArray*)result;
        }
        block?block(yesOrNo, result):nil;
    }];
}

+(VcashSlate*)createSendTransaction:(NSString*)targetUserId amount:(uint64_t)amount fee:(uint64_t)fee withComplete:(RequestCompleteBlock)block{
    [[VcashWallet shareInstance] sendTransaction:amount andFee:fee withComplete:^(BOOL yesOrNO, id data) {
        block?block(yesOrNO, data):nil;
    }];

    return nil;
}

+(void)sendTransaction:(VcashSlate*)slate{
    
}

#pragma private
+(BOOL)checkWalletState{
    return [VcashWallet shareInstance]?YES:NO;
}

@end
