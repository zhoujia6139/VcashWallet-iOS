//
//  VcashTypes.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/22.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashTypes.h"
#import "VcashSecp256k1.h"
#import "VcashWallet.h"
#include "blake2.h"

@implementation Input
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.commit = [PublicTool getDataFromArray:dic[@"commit"]];
    
    NSString* fea = dic[@"features"];
    if ([fea isEqualToString:@"Plain"]){
        self.features = OutputFeaturePlain;
    }
    else if ([fea isEqualToString:@"Coinbase"]){
        self.features = OutputFeatureCoinbase;
    }
    
    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    dic[@"commit"] = [PublicTool getArrFromData:self.commit];
    
    if (self.features == OutputFeaturePlain){
        dic[@"features"] = @"Plain";
    }
    else if (self.features == OutputFeatureCoinbase){
        dic[@"features"] = @"Coinbase";
    }
    
    return YES;
}

@end

@implementation Output
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.commit = [PublicTool getDataFromArray:dic[@"commit"]];
    self.proof = [PublicTool getDataFromArray:dic[@"proof"]];
    
    NSString* fea = dic[@"features"];
    if ([fea isEqualToString:@"Plain"]){
        self.features = OutputFeaturePlain;
    }
    else if ([fea isEqualToString:@"Coinbase"]){
        self.features = OutputFeatureCoinbase;
    }
    
    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    dic[@"commit"] = [PublicTool getArrFromData:self.commit];
    
    dic[@"proof"] = [PublicTool getArrFromData:self.proof];
    
    if (self.features == OutputFeaturePlain){
        dic[@"features"] = @"Plain";
    }
    else if (self.features == OutputFeatureCoinbase){
        dic[@"features"] = @"Coinbase";
    }
    
    return YES;
}

@end

@implementation TxKernel

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.excess = [PublicTool getDataFromArray:dic[@"excess"]];
    self.excess_sig = [PublicTool getDataFromArray:dic[@"excess_sig"]];
    
    NSString* fea = dic[@"features"];
    if ([fea isEqualToString:@"Plain"]){
        self.features = KernelFeaturePlain;
    }
    else if ([fea isEqualToString:@"Coinbase"]){
        self.features = KernelFeatureCoinbase;
    }
    else if ([fea isEqualToString:@"HeightLocked"]){
        self.features = KernelFeatureHeightLocked;
    }
    
    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    dic[@"excess"] = [PublicTool getArrFromData:self.excess];

    dic[@"excess_sig"] = [PublicTool getArrFromData:self.excess_sig];
    
    if (self.features == KernelFeaturePlain){
        dic[@"features"] = @"Plain";
    }
    else if (self.features == KernelFeatureCoinbase){
        dic[@"features"] = @"Coinbase";
    }
    else if (self.features == KernelFeatureHeightLocked){
        dic[@"features"] = @"HeightLocked";
    }
    return YES;
}

-(NSData*)excess{
    if (!_excess){
        uint8_t buf[PEDERSEN_COMMITMENT_SIZE] = {0};
        _excess = [[NSData alloc] initWithBytes:buf length:PEDERSEN_COMMITMENT_SIZE];
    }
    return _excess;
}

-(NSData*)excess_sig{
    if (!_excess_sig){
        uint8_t buf[64] = {0};
        _excess_sig = [[NSData alloc] initWithBytes:buf length:64];
    }
    return _excess_sig;
}

-(void)setLock_height:(uint64_t)lock_height{
    _lock_height = lock_height;
    _features = [TxKernel featureWithLockHeight:lock_height];
}

-(BOOL)verify{
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    
    NSData* pubkey = [secp commitToPubkey:self.excess];
    if (pubkey){
        if ([secp verifySingleSignature:self.excess_sig pubkey:pubkey nonceSum:nil pubkeySum:pubkey andMsgData:[self kernelMsgToSign]]){
            return YES;
        }
    }
    
    return NO;
}

-(NSData*)kernelMsgToSign{
    NSData* data = nil;
    switch (self.features) {
        case KernelFeaturePlain:
        {
            if (self.lock_height == 0){
                uint8_t buf[9];
                buf[0] = self.features;
                OSWriteBigInt64(buf, 1, self.fee);
                data = [[NSData alloc] initWithBytes:buf length:9];
            }
            break;
        }
            
        case KernelFeatureCoinbase:
        {
            if (self.fee == 0 && self.lock_height == 0){
                uint8_t buf[1];
                buf[0] = self.features;
                data = [NSData dataWithBytes:buf length:1];
            }
            break;
        }
            
        case KernelFeatureHeightLocked:
        {
            uint8_t buf[17];
            buf[0] = self.features;
            OSWriteBigInt64(buf, 1, self.fee);
            OSWriteBigInt64(buf, 9, self.lock_height);
            data = [[NSData alloc] initWithBytes:buf length:17];
            break;
        }
            
        default:
            break;
    }
    
    uint8_t ret[32];
    if( blake2b( ret, data.bytes, nil, 32, data.length, 0 ) < 0)
    {
        return nil;
    }
    
    return [[NSData alloc] initWithBytes:ret length:32];
}

+(KernelFeatures)featureWithLockHeight:(uint64_t)lock_height{
    return lock_height>0?KernelFeatureHeightLocked:KernelFeaturePlain;
}

@end

@implementation TransactionBody

-(id)init{
    self = [super init];
    if (self){
        _inputs = [NSMutableArray new];
        _outputs = [NSMutableArray new];
        _kernels = [NSMutableArray new];
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"inputs" : [Input class],
             @"outputs" : [Output class],
             @"kernels" : [TxKernel class],
             };
}

@end

@implementation VcashTransaction
-(id)init{
    self = [super init];
    if (self){
        _body = [TransactionBody new];
    }
    return self;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.offset = [PublicTool getDataFromArray:dic[@"offset"]];
    
    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    dic[@"offset"] = [PublicTool getArrFromData:self.offset];
    
    return YES;
}

-(NSData*)calculateFinalExcess{
    NSMutableArray* negativeCommits = [NSMutableArray new];
    NSMutableArray* positiveCommits = [NSMutableArray new];
    for (Input* input in self.body.inputs){
        [negativeCommits addObject:input.commit];
    }
    for (Output* output in self.body.outputs){
        [positiveCommits addObject:output.commit];
    }
    
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    uint64_t fee = 0;
    for (TxKernel* kernel in self.body.kernels){
        fee += kernel.fee;
    }
    NSData* feeCommit = [secp commitment:fee withKey:[VcashSecretKey zeroKey]];
    [positiveCommits addObject:feeCommit];
    
    NSData* offsetCommit = [secp commitment:0 withKey:[[VcashSecretKey alloc] initWithData:self.offset]];
    [negativeCommits addObject:offsetCommit];
    NSData* commit = [secp commitSumWithPositiveArr:positiveCommits andNegative:negativeCommits];
    return commit;
}

-(BOOL)setTxExcess:(NSData*)excess andTxSig:(NSData*)sig{
    if (self.body.kernels.count == 1){
        TxKernel* kernel = [self.body.kernels objectAtIndex:0];
        kernel.excess = excess;
        kernel.excess_sig = sig;
        if ([kernel verify]){
            return YES;
        }
    }
    
    return NO;
}


@end

@implementation VcashProofInfo

@end


