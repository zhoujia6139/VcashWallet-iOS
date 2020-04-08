//
//  VcashWallet.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/20.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VcashKeyChain.h"
#import "VcashTypes.h"
#import "NodeType.h"
#import "VcashKeychainPath.h"
#import "VcashDataManager.h"
#import "ServerType.h"

NS_ASSUME_NONNULL_BEGIN

#define kWalletChainHeightChange @"kWalletChainHeightChange"

@class WalletBalanceInfo,VcashOutput,VcashTokenOutput;

@interface VcashWallet : NSObject

+(void)createWalletWithKeyChain:(VcashKeyChain*)keychain;

+ (instancetype)shareInstance;

@property (readonly, strong, nonatomic)VcashKeyChain* mKeyChain;

@property (assign, nonatomic, readonly)uint64_t curChainHeight;

@property(strong, nonatomic, readonly)NSArray<VcashOutput*>* outputs;

@property(strong, nonatomic, readonly)NSDictionary<NSString*, NSArray<VcashTokenOutput*>*>* token_outputs_dic;

@property(strong, nonatomic, readonly)NSString* userId;

-(NSData*)getPaymentProofKey;

-(WalletBalanceInfo*)getWalletBalanceInfo;

-(WalletBalanceInfo*)getWalletTokenBalanceInfo:(NSString*)tokenType;

//only call after recover
-(void)setChainOutputs:(NSArray*)arr;

-(void)addNewTxChangeOutput:(VcashOutput*)output;

-(void)syncOutputInfo;

-(void)reloadOutputInfo;

//only call after recover
-(void)setChainTokenOutputs:(NSArray*)arr;

-(void)addNewTokenTxChangeOutput:(VcashTokenOutput*)output;

-(void)syncTokenOutputInfo;

-(void)reloadTokenOutputInfo;

-(id)identifyUtxoOutput:(NodeOutput*)nodeOutput;

-(void)sendTransaction:(uint64_t)amount andFee:(uint64_t)fee withComplete:(RequestCompleteBlock)block;

-(void)sendTokenTransaction:(NSString*)token_type andAmount:(uint64_t)amount withComplete:(RequestCompleteBlock)block;

-(BOOL)receiveTransaction:(VcashSlate*)slate;

-(BOOL)finalizeTransaction:(VcashSlate*)slate;

-(VcashKeychainPath*)nextChild;

-(uint32_t)getNextLogId;

-(NSData*)getSignerKey;

@end


@interface WalletBalanceInfo : NSObject

@property(assign, nonatomic)uint64_t total;

@property(assign, nonatomic)uint64_t locked;

@property(assign, nonatomic)uint64_t unconfirmed;

@property(assign, nonatomic)uint64_t spendable;

@end

NS_ASSUME_NONNULL_END
