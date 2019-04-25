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

@interface VcashWallet : NSObject

+(void)createWalletWithKeyChain:(VcashKeyChain*)keychain;

+ (instancetype)shareInstance;

@property (readonly, strong, nonatomic)VcashKeyChain* mKeyChain;

@property (strong, nonatomic, readonly)VcashKeychainPath* curKeyPath;

@property (assign, nonatomic, readonly)uint64_t curChainHeight;

@property(strong, nonatomic, readonly)NSArray<VcashOutput*>* outputs;

//only call after recover
-(void)setChainOutputs:(NSArray*)arr;

-(VcashOutput*)identifyUtxoOutput:(NodeOutput*)nodeOutput;

-(VcashSlate*)sendTransaction:(uint64_t)amount andFee:(uint64_t)fee withComplete:(RequestCompleteBlock)block;

-(void)receiveTransaction:(VcashSlate*)slate;

-(VcashKeychainPath*)nextChild;

@end

NS_ASSUME_NONNULL_END
