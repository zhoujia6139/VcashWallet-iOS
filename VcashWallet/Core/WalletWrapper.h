//
//  WalletWrapper.h
//  PoolinWallet
//
//  Created by jia zhou on 2018/7/31.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NodeApi.h"
#import "VcashTypes.h"
#import "VcashDataManager.h"
#import "VcashWallet.h"

@interface WalletWrapper : NSObject

+(NSArray*)getAllPhraseWords;

+(NSArray*)generateMnemonicPassphrase;

+(BOOL)createWalletWithPhrase:(NSArray*)wordsArr nickname:(NSString*)nickname password:(NSString*)password;

//clear wallet
+(void)clearWallet;

+(NSString*)getWalletUserId;

+(WalletBalanceInfo*)getWalletBalanceInfo;

//check wallet utxo
+(void)checkWalletUtxoWithComplete:(RequestCompleteBlock)block;

//TODO support multi receiver
+(void)createSendTransaction:(NSString*)targetUserId amount:(uint64_t)amount fee:(uint64_t)fee withComplete:(RequestCompleteBlock)block;

//send Transaction
+(void)sendTransaction:(VcashSlate*)slate forUser:(NSString*)user withComplete:(RequestCompleteBlock)block;

+(void)receiveTransaction:(ServerTransaction*)tx withComplete:(RequestCompleteBlock)block;

+(void)finalizeTransaction:(ServerTransaction*)tx withComplete:(RequestCompleteBlock)block;

//refresh Transaction
+(NSArray*)getTransationArr;

+(void)updateOutputStatusWithComplete:(RequestCompleteBlock)block;

+(double)nanoToVcash:(int64_t)nano;

+(int64_t)vcashToNano:(double)vcash;

@end

