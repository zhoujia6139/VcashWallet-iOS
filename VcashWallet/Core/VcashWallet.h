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

NS_ASSUME_NONNULL_BEGIN

@interface VcashWallet : NSObject

@property (readonly, strong, nonatomic)VcashKeyChain* mKeyChain;

+(void)createWalletWithKeyChain:(VcashKeyChain*)keychain;

+ (instancetype)shareInstance;

@property(strong, nonatomic)NSArray<VcashOutput*>* outputs;

-(NSArray*)collectChainOutputs;

-(VcashOutput*)identifyUtxoOutput:(NodeOutput*)nodeOutput;

-(void)sendTransaction:(VcashSlate*)slate amount:(uint64_t)amount andFee:(uint64_t)fee withComplete:(RequestCompleteBlock)block;



@end

NS_ASSUME_NONNULL_END
