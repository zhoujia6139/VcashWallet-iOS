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

NS_ASSUME_NONNULL_BEGIN

@class WalletBalanceInfo,VcashOutput;

@interface VcashWallet : NSObject

+(void)createWalletWithKeyChain:(VcashKeyChain*)keychain;

+ (instancetype)shareInstance;

@property (readonly, strong, nonatomic)VcashKeyChain* mKeyChain;

@property (strong, nonatomic, readonly)VcashKeychainPath* curKeyPath;

@property (assign, nonatomic, readonly)uint64_t curChainHeight;

@property(strong, nonatomic, readonly)NSArray<VcashOutput*>* outputs;

-(WalletBalanceInfo*)getWalletBalanceInfo;

//only call after recover
-(void)setChainOutputs:(NSArray*)arr;

-(void)addNewTxChangeOutput:(VcashOutput*)output;

-(void)syncOutputInfo;

-(VcashOutput*)identifyUtxoOutput:(NodeOutput*)nodeOutput;

-(VcashSlate*)sendTransaction:(uint64_t)amount andFee:(uint64_t)fee withComplete:(RequestCompleteBlock)block;

-(VcashSlate*)receiveTransaction:(VcashSlate*)slate;

-(BOOL)finalizeTransaction:(VcashSlate*)slate;

-(VcashKeychainPath*)nextChild;

@end


@interface WalletBalanceInfo : NSObject

@property(assign, nonatomic)uint64_t total;

@property(assign, nonatomic)uint64_t locked;

@property(assign, nonatomic)uint64_t unconfirmed;

@property(assign, nonatomic)uint64_t spendable;

@end

NS_ASSUME_NONNULL_END
