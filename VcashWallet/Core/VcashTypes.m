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

-(NSData*)computePayload{
    NSMutableData* data = [NSMutableData new];
    uint8_t feature = self.features;
    [data appendBytes:&feature length:1];
    [data appendData:self.commit];
    return data;
}

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

-(NSData*)computePayload{
    NSMutableData* data = [NSMutableData new];
    uint8_t feature = self.features;
    [data appendBytes:&feature length:1];
    [data appendData:self.commit];
    [data appendData:self.proof];
    return data;
}

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

-(NSData*)computePayload{
    NSMutableData* data = [NSMutableData new];
    uint8_t feature = self.features;
    [data appendBytes:&feature length:1];
    uint8_t buf[16];
    OSWriteBigInt64(buf, 0, self.fee);
    OSWriteBigInt64(buf, 8, self.lock_height);
    [data appendBytes:buf length:16];
    [data appendData:self.excess];
    [data appendData:[self.excess_sig getCompactData]];
    return data;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.excess = [PublicTool getDataFromArray:dic[@"excess"]];
    
    NSData* compactExessSig = [PublicTool getDataFromArray:dic[@"excess_sig"]];
    self.excess_sig = [[VcashSignature alloc] initWithCompactData:compactExessSig];
    
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

    dic[@"excess_sig"] = [PublicTool getArrFromData:[self.excess_sig getCompactData]];
    
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

-(VcashSignature*)excess_sig{
    if (!_excess_sig){
        _excess_sig = [VcashSignature zeroSignature];
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

-(NSData*)computePayload{
    NSMutableData* data = [NSMutableData new];
    uint8_t buf[24];
    OSWriteBigInt64(buf, 0, self.inputs.count);
    OSWriteBigInt64(buf, 8, self.outputs.count);
    OSWriteBigInt64(buf, 16, self.kernels.count);
    [data appendBytes:buf length:24];
    
    for (Input* item in self.inputs){
        [data appendData:[item computePayload]];
    }
    
    for (Output* item in self.outputs){
        [data appendData:[item computePayload]];
    }
    
    for (TxKernel* item in self.kernels){
        [data appendData:[item computePayload]];
    }
    
    return data;
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

-(BOOL)setTxExcess:(NSData*)excess andTxSig:(VcashSignature*)sig{
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

-(NSData*)computePayload{
    NSMutableData* data = [NSMutableData new];
    [data appendData:self.offset];
    [data appendData:[self.body computePayload]];
    return data;
}

@end

@implementation VcashProofInfo

@end

@implementation VcashSignature

+(instancetype)zeroSignature{
    VcashSignature* sig = [VcashSignature new];
    uint8_t buf[64] = {0};
    sig.sig_data = [[NSData alloc] initWithBytes:buf length:64];
    return sig;
}

-(instancetype)initWithCompactData:(NSData*)compactData{
    self = [super init];
    if (self) {
        VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
        self.sig_data = [secp compactDataToSignature:compactData];
        if (self.sig_data){
            return self;
        }
    }
    
    return nil;
}

-(instancetype)initWithData:(NSData*)sigData{
    self = [super init];
    if (self){
        self.sig_data = sigData;
    }
    
    return self;
}

-(NSData*)getCompactData{
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    return [secp signatureToCompactData:self.sig_data];
}

@end


