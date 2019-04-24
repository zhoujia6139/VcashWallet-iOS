//
//  VcashWallet.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/20.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashWallet.h"
#import "VcashContext.h"

#define DEFAULT_BASE_FEE 1000000

static VcashWallet* walletInstance = nil;

@interface VcashWallet()

@property (strong, nonatomic)VcashKeyChain* mKeyChain;

@end

@implementation VcashWallet

+(void)createWalletWithKeyChain:(VcashKeyChain*)keychain{
    if (keychain && !walletInstance){
        walletInstance = [[self alloc] init];
        walletInstance.mKeyChain = keychain;
    }
}

+ (instancetype)shareInstance{
    return walletInstance;
}

-(NSArray*)collectChainOutputs{
    return nil;
}

-(VcashOutput*)identifyUtxoOutput:(NodeOutput*)nodeOutput{
    NSData* commit = BTCDataFromHex(nodeOutput.commit);
    NSData* proof = BTCDataFromHex(nodeOutput.proof);
    VcashProofInfo* info = [self.mKeyChain rewindProof:commit withProof:proof];
    if (info.isSuc){
        VcashOutput* output = [VcashOutput new];
        output.commit = nodeOutput.commit;
        output.keyPath = [[VcashKeychainPath alloc] initWithDepth:3 andPathData:info.message].pathStr;
        output.mmr_index = nodeOutput.mmr_index;
        output.value = info.value;
        output.height = nodeOutput.block_height;
        output.is_coinbase = [nodeOutput.output_type isEqualToString:@"Coinbase"];
        if (output.is_coinbase){
            output.lock_height = nodeOutput.block_height + 144;
        }
        else{
            output.lock_height = nodeOutput.block_height;
        }
        output.status = Unspent;
        output.blinding = info.secretKey;
        
        return output;
    }

    return nil;
}

-(void)sendTransaction:(uint64_t)amount andFee:(uint64_t)fee withComplete:(RequestCompleteBlock)block{
    uint64_t total = 0;
    for (VcashOutput* item in self.outputs){
        total += item.value;
    }
    
    //1 Compute Fee and output
    // 1.1First attempt to spend without change
    uint64_t actualFee = fee;
    if (fee == 0){
        actualFee = [self calcuteFee:self.outputs.count withOutputCount:1];
    }
    
    uint64_t amount_with_fee = amount + actualFee;
    if (total < amount_with_fee){
        NSString* errMsg = [NSString stringWithFormat:@"Not enough funds, available:%lld, needed:%lld", total, amount_with_fee];
        block?block(NO, errMsg):nil;
    }
    
    // 1.2Second attempt to spend with change
    if (total != amount_with_fee) {
        actualFee = [self calcuteFee:self.outputs.count withOutputCount:2];
    }
    
    uint64_t change = total - amount_with_fee;
    
    //2 fill slate
    VcashSlate* slate = [VcashSlate new];
    slate.num_participants = 2;
    slate.amount = amount;
    slate.height = 176;
    slate.lock_height = 176;
    slate.fee = actualFee;
    VcashSecretKey* blind = [slate addTxElement:self.outputs change:change];
    
    //3 construct Context
    VcashContext* context = [[VcashContext alloc] init];
    context.sec_key = blind;
    
    //4 fill round 1
    [slate fillRound1:context participantId:0 andMessage:@""];
}

-(VcashKeychainPath*)nextChild{
    self.curKeyPath = [self.curKeyPath nextPath];
    return self.curKeyPath;
}

#pragma private
-(uint64_t)calcuteFee:(NSInteger)inputCount withOutputCount:(NSInteger)outputCount{
    NSInteger tx_weight = outputCount * 4 + 1 - inputCount;
    tx_weight = (tx_weight>1?tx_weight:1);
    
    return DEFAULT_BASE_FEE*tx_weight;
}

@end
