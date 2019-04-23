//
//  VcashSlate.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashSlate.h"
#import "CoreBitCoin.h"
#import "VcashTransaction.h"
#import "VcashWallet.h"
#import "VcashKeychainPath.h"

@implementation VcashSlate

-(id)init{
    self = [super init];
    if (self){
        _uuid = @"";
        _version = 1;
        _tx = [VcashTransaction new];
    }
    return self;
}

-(void)addTxElement:(NSArray*)outputs change:(uint64_t)change{
    VcashTransaction* tx = self.tx;
    TxKernel* txKernel = [TxKernel new];
    BTCMutableBigNumber* blindSum = [BTCMutableBigNumber zero];
    
    //1,fee
    txKernel.fee = self.fee;
    
    //2,input
    for (VcashOutput* item in outputs){
        VcashKeychainPath* keypath = [[VcashKeychainPath alloc] initWithPathstr:item.keyPath];
        NSData*commitment = [[VcashWallet shareInstance].mKeyChain createCommitment:item.value andKeypath:keypath];
        Input* input = [Input new];
        input.commit = commitment;
        input.features = (item.is_coinbase?OutputFeatureCoinbase:OutputFeaturePlain);
        [tx.body.inputs addObject:input];
    }
    
}

@end
