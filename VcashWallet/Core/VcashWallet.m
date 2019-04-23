//
//  VcashWallet.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/20.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashWallet.h"

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

@end
