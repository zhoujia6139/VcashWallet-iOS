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
#import "VcashTokenInfo.h"

@interface WalletWrapper : NSObject

+(NSArray*)getAllPhraseWords;

+(NSArray*)generateMnemonicPassphrase;

+(BOOL)createWalletWithPhrase:(NSArray*)wordsArr nickname:(NSString*)nickname password:(NSString*)password;

//clear wallet
+(void)clearWallet;

// payment proof

+(BOOL)isValidSlatePackAddress:(NSString*)address;

+(NSString*)getPubkeyFromProofAddress:(NSString*)proofAddress;

+(NSString*)getProofAddressFromPublicKey:(NSString*)publicKey;

+(NSString*)createPaymentProofSignature:(NSString*)token_type amount:(int64_t)amount excess:(NSString*)excess andSenderPubkey:(NSString*)senderPubkey andSecretKey:(NSString*)secKey;

+(Boolean)verifyPaymentProof:(NSString*)token_type amount:(int64_t)amount excess:(NSString*)excess senderPubkey:(NSString*)senderPubkey verifyPubkey:(NSString*)receiverPubkey andSignature:(NSString*)signature;

+(NSString*)exportPaymentProof:(VcashSlate*)slate;

+(void)verifyPaymentProof:(NSString*)proof WithComplete:(RequestCompleteBlock)block;

//slate pack
+(VcashSlate*)parseSlateFromEncrypedSlatePackStr:(NSString*)slateStr;

+(NSString*)encryptSlateForParter:(VcashSlate*)slate;

//base info
+(NSString*)getWalletUserId;

+(WalletBalanceInfo*)getWalletBalanceInfo;

+(NSArray*)getBalancedToken;

+(WalletBalanceInfo*)getWalletTokenBalanceInfo:(NSString*)tokenType;

+(uint64_t)getCurChainHeight;

//check wallet utxo
+(void)checkWalletUtxoFromIndex:(uint64_t)startIndex WithComplete:(RequestCompleteBlock)block;

+(void)checkWalletTokenUtxoFromIndex:(uint64_t)startIndex WithComplete:(RequestCompleteBlock)block;

//TODO support multi receiver
+(void)createSendTransaction:(NSString*)tokenType andAmount:(uint64_t)amount andProofAddress:(NSString*)proofAddress withComplete:(RequestCompleteBlock)block;

//send Transaction
+(void)sendTransaction:(VcashSlate*)slate forUser:(NSString*)user withComplete:(RequestCompleteBlock)block;

+(void)sendTransaction:(VcashSlate*)slate forUrl:(NSString*)url withComplete:(RequestCompleteBlock)block;

+(void)sendTransactionByFile:(VcashSlate*)slate withComplete:(RequestCompleteBlock)block;

//receive Transaction
+(void)isValidSlateConentForReceive:(NSString*)slateStr withComplete:(RequestCompleteBlock)block;

+(void)receiveTransactionBySlate:(VcashSlate*)slate withComplete:(RequestCompleteBlock)block;

+(void)receiveTransaction:(ServerTransaction*)tx withComplete:(RequestCompleteBlock)block;

//finalize Transaction
+(void)isValidSlateConentForFinalize:(NSString*)slateStr withComplete:(RequestCompleteBlock)block;

+(void)finalizeServerTx:(ServerTransaction*)tx withComplete:(RequestCompleteBlock)block;

+(void)finalizeTransaction:(VcashSlate*)slate withComplete:(RequestCompleteBlock)block;

+(BOOL)cancelTransaction:(NSString*)tx_id;

//refresh Transaction
+(void)updateTxStatus;

+(NSArray*)getTransationArr;

+(BaseVcashTxLog*)getTxByTxid:(NSString*)txid;

+(Boolean)deleteTxByTxid:(NSString*)txid;

+(NSArray*)getFileReceiveTxArr;

+(void)updateOutputStatusWithComplete:(RequestCompleteBlock)block;

//refresh token Transaction
+(NSArray*)getTokenTxArr:(NSString*)tokenType;

+(Boolean)deleteTokenTxByTxid:(NSString*)txid;

+(void)updateTokenOutputStatusWithComplete:(RequestCompleteBlock)block;

+(void)initTokenInfos;

+(NSArray*)getAllTokens;

+(VcashTokenInfo*)getTokenInfo:(NSString*)tokenId;

+(NSArray*)getAddedTokens;

+(void)addAddedToken:(NSString*)tokenType;

+(void)deleteAddedToken:(NSString*)tokenType;

+(double)nanoToVcash:(int64_t)nano;

+(int64_t)vcashToNano:(double)vcash;

@end

