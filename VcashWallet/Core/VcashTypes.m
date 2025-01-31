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

@implementation TxBaseObject

-(NSData*)computePayloadForHash:(BOOL)yesOrNo{
    return nil;
}

-(NSData*)blake2bHash{
    NSData* payload = [self computePayloadForHash:YES];
    uint8_t ret[32];
    if( blake2b( ret, payload.bytes, nil, 32, payload.length, 0 ) < 0)
    {
        return nil;
    }
    
    return [[NSData alloc] initWithBytes:ret length:32];
}

@end

@implementation Input

-(NSData*)computePayloadForHash:(BOOL)yesOrNo{
    NSMutableData* data = [NSMutableData new];
    uint8_t feature = self.features;
    [data appendBytes:&feature length:1];
    [data appendData:self.commit];
    return data;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.commit = BTCDataFromHex(dic[@"commit"]);
    
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
    dic[@"commit"] = BTCHexFromData(self.commit);
    
    if (self.features == OutputFeaturePlain){
        dic[@"features"] = @"Plain";
    }
    else if (self.features == OutputFeatureCoinbase){
        dic[@"features"] = @"Coinbase";
    }
    
    return YES;
}

@end

@implementation TokenInput

-(NSData*)computePayloadForHash:(BOOL)yesOrNo{
    NSMutableData* data = [NSMutableData new];
    uint8_t feature = self.features;
    [data appendBytes:&feature length:1];
    [data appendData:BTCDataFromHex(self.token_type)];
    [data appendData:self.commit];
    return data;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.commit = BTCDataFromHex(dic[@"commit"]);
    
    self.token_type = dic[@"token_type"];
    
    NSString* fea = dic[@"features"];
    if ([fea isEqualToString:@"Token"]){
        self.features = OutputFeatureToken;
    }
    else if ([fea isEqualToString:@"TokenIssue"]){
        self.features = OutputFeatureTokenIssue;
    }
    
    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    dic[@"commit"] = BTCHexFromData(self.commit);
    
    dic[@"token_type"] = self.token_type;
    
    if (self.features == OutputFeatureToken){
        dic[@"features"] = @"Token";
    }
    else if (self.features == OutputFeatureTokenIssue){
        dic[@"features"] = @"TokenIssue";
    }
    
    return YES;
}

@end

@implementation Output

-(NSData*)computePayloadForHash:(BOOL)yesOrNo{
    NSMutableData* data = [NSMutableData new];
    uint8_t feature = self.features;
    [data appendBytes:&feature length:1];
    [data appendData:self.commit];
    if (!yesOrNo){
        uint8_t buf[8];
        OSWriteBigInt64(buf, 0, self.proof.length);
        [data appendBytes:buf length:8];
        [data appendData:self.proof];
    }
    
    return data;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.commit = BTCDataFromHex(dic[@"commit"]);
    self.proof = BTCDataFromHex(dic[@"proof"]);
    
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
    dic[@"commit"] = BTCHexFromData(self.commit);
    
    dic[@"proof"] = BTCHexFromData(self.proof);
    
    if (self.features == OutputFeaturePlain){
        dic[@"features"] = @"Plain";
    }
    else if (self.features == OutputFeatureCoinbase){
        dic[@"features"] = @"Coinbase";
    }
    
    return YES;
}

@end

@implementation TokenOutput

-(NSData*)computePayloadForHash:(BOOL)yesOrNo{
    NSMutableData* data = [NSMutableData new];
    uint8_t feature = self.features;
    [data appendBytes:&feature length:1];
    [data appendData:BTCDataFromHex(self.token_type)];
    [data appendData:self.commit];
    if (!yesOrNo){
        uint8_t buf[8];
        OSWriteBigInt64(buf, 0, self.proof.length);
        [data appendBytes:buf length:8];
        [data appendData:self.proof];
    }
    
    return data;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.commit = BTCDataFromHex(dic[@"commit"]);
    
    self.token_type = dic[@"token_type"];
    
    self.proof = BTCDataFromHex(dic[@"proof"]);
    
    NSString* fea = dic[@"features"];
    if ([fea isEqualToString:@"Token"]){
        self.features = OutputFeatureToken;
    }
    else if ([fea isEqualToString:@"TokenIssue"]){
        self.features = OutputFeatureTokenIssue;
    }
    
    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    dic[@"commit"] = BTCHexFromData(self.commit);
    
    dic[@"token_type"] = self.token_type;
    
    dic[@"proof"] = BTCHexFromData(self.proof);
    
    if (self.features == OutputFeatureToken){
        dic[@"features"] = @"Token";
    }
    else if (self.features == OutputFeatureTokenIssue){
        dic[@"features"] = @"TokenIssue";
    }
    
    return YES;
}

@end

@implementation TxKernel

-(NSData*)computePayloadForHash:(BOOL)yesOrNo{
    NSMutableData* data = [NSMutableData new];
    uint8_t feature = self.features;
    [data appendBytes:&feature length:1];
    if (self.features == KernelFeaturePlain) {
        uint8_t buf[8];
        OSWriteBigInt64(buf, 0, self.fee);
        [data appendBytes:buf length:8];
    } else if (self.features == KernelFeatureHeightLocked) {
        uint8_t buf[16];
        OSWriteBigInt64(buf, 0, self.fee);
        OSWriteBigInt64(buf, 8, self.lock_height);
        [data appendBytes:buf length:16];
    }

    [data appendData:self.excess];
    [data appendData:self.excess_sig.sig_data];
    return data;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.excess = BTCDataFromHex(dic[@"excess"]);
    
    NSData* compactExessSig = BTCDataFromHex(dic[@"excess_sig"]);
    self.excess_sig = [[VcashSignature alloc] initWithCompactData:compactExessSig];
    
    NSString* feature = dic[@"features"];
    if ([feature isEqualToString:@"Plain"]) {
        self.features = KernelFeaturePlain;
    } else if ([feature isEqualToString:@"Coinbase"]) {
        self.features = KernelFeatureCoinbase;
    } else if ([feature isEqualToString:@"HeightLocked"]) {
        self.features = KernelFeatureHeightLocked;
    }
    
    self.fee = [[dic valueForKey:@"fee"] longLongValue];
    self.lock_height = [[dic valueForKey:@"lock_height"] longLongValue];

    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    dic[@"excess"] = BTCHexFromData(self.excess);

    dic[@"excess_sig"] = BTCHexFromData([self.excess_sig getCompactData]);
    
    if (self.features == KernelFeaturePlain){
        dic[@"features"] = @"Plain";
    }
    else if (self.features == KernelFeatureCoinbase){
        dic[@"features"] = @"Coinbase";
    }
    else if (self.features == KernelFeatureHeightLocked){
        dic[@"features"] = @"HeightLocked";
    }
    
    dic[@"fee"] = [NSNumber numberWithLongLong:self.fee];
    dic[@"lock_height"] = [NSNumber numberWithLongLong:self.lock_height];
    
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

@implementation TokenTxKernel

-(NSData*)computePayloadForHash:(BOOL)yesOrNo{
    NSMutableData* data = [NSMutableData new];
    uint8_t feature = self.features;
    [data appendBytes:&feature length:1];
    if (feature == KernelFeatureHeightLockedToken) {
        uint8_t buf[8];
        OSWriteBigInt64(buf, 8, self.lock_height);
        [data appendBytes:buf length:8];
    }
    [data appendData:BTCDataFromHex(self.token_type)];
    [data appendData:self.excess];
    [data appendData:self.excess_sig.sig_data];
    return data;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.excess = BTCDataFromHex(dic[@"excess"]);
    
    NSData* compactExessSig = BTCDataFromHex(dic[@"excess_sig"]);
    self.excess_sig = [[VcashSignature alloc] initWithCompactData:compactExessSig];
    
    NSString* fea = dic[@"features"];
    if ([fea isEqualToString:@"PlainToken"]){
        self.features = KernelFeaturePlainToken;
    }
    else if ([fea isEqualToString:@"IssueToken"]){
        self.features = KernelFeatureIssueToken;
    }
    
    self.token_type = dic[@"token_type"];
    
    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    dic[@"excess"] = BTCHexFromData(self.excess);
    
    dic[@"excess_sig"] = BTCHexFromData([self.excess_sig getCompactData]);
    
    if (self.features == KernelFeaturePlainToken){
        dic[@"features"] = @"PlainToken";
    }
    else if (self.features == KernelFeatureIssueToken){
        dic[@"features"] = @"IssueToken";
    }
    
    dic[@"token_type"] = self.token_type;
    
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
    _features = [TokenTxKernel featureWithLockHeight:lock_height];
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
    NSMutableData* data = [NSMutableData new];
    uint8_t feature = self.features;
    [data appendBytes:&feature length:1];
    [data appendData:BTCDataFromHex(self.token_type)];
    if (self.features == KernelFeatureHeightLockedToken){
        uint8_t buf[8];
        OSWriteBigInt64(buf, 1, self.lock_height);
        [data appendBytes:buf length:8];
    }
    
    uint8_t ret[32];
    if( blake2b( ret, data.bytes, nil, 32, data.length, 0 ) < 0)
    {
        return nil;
    }
    
    return [[NSData alloc] initWithBytes:ret length:32];
}

+(TokenKernelFeatures)featureWithLockHeight:(uint64_t)lock_height{
    return lock_height>0?KernelFeatureHeightLockedToken:KernelFeaturePlainToken;
}

@end

@implementation TransactionBody

-(id)init{
    self = [super init];
    if (self){
        _inputs = [NSMutableArray new];
        _token_inputs = [NSMutableArray new];
        _outputs = [NSMutableArray new];
        _token_outputs = [NSMutableArray new];
        _kernels = [NSMutableArray new];
        _token_kernels = [NSMutableArray new];
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"inputs" : [Input class],
             @"outputs" : [Output class],
             @"kernels" : [TxKernel class],
             @"token_inputs" : [TokenInput class],
             @"token_outputs" : [TokenOutput class],
             @"token_kernels" : [TokenTxKernel class],
             };
}

-(NSData*)computePayloadForHash:(BOOL)yesOrNo{
    NSMutableData* data = [NSMutableData new];
    uint8_t buf[48];
    OSWriteBigInt64(buf, 0, self.inputs.count);
    OSWriteBigInt64(buf, 8, self.token_inputs.count);
    OSWriteBigInt64(buf, 16, self.outputs.count);
    OSWriteBigInt64(buf, 24, self.token_outputs.count);
    OSWriteBigInt64(buf, 32, self.kernels.count);
    OSWriteBigInt64(buf, 40, self.token_kernels.count);
    [data appendBytes:buf length:48];
    
    for (Input* item in self.inputs){
        [data appendData:[item computePayloadForHash:yesOrNo]];
    }
    
    for (TokenInput* item in self.token_inputs){
        [data appendData:[item computePayloadForHash:yesOrNo]];
    }
    
    for (Output* item in self.outputs){
        [data appendData:[item computePayloadForHash:yesOrNo]];
    }
    
    for (TokenOutput* item in self.token_outputs){
        [data appendData:[item computePayloadForHash:yesOrNo]];
    }
    
    for (TxKernel* item in self.kernels){
        [data appendData:[item computePayloadForHash:yesOrNo]];
    }
    
    for (TokenTxKernel* item in self.token_kernels){
        [data appendData:[item computePayloadForHash:yesOrNo]];
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
    self.offset = BTCDataFromHex(dic[@"offset"]);
    
    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    dic[@"offset"] = BTCHexFromData(self.offset);
    
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

//-(NSData*)calculateTokenFinalExcess{
//    NSMutableArray* negativeCommits = [NSMutableArray new];
//    NSMutableArray* positiveCommits = [NSMutableArray new];
//    for (TokenInput* input in self.body.token_inputs){
//        [negativeCommits addObject:input.commit];
//    }
//    for (TokenOutput* output in self.body.token_outputs){
//        [positiveCommits addObject:output.commit];
//    }
//    
//    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
//    NSData* commit = [secp commitSumWithPositiveArr:positiveCommits andNegative:negativeCommits];
//    return commit;
//}

-(BOOL)setTokenTxExcess:(NSData*)excess andTxSig:(VcashSignature*)sig{
    if (self.body.token_kernels.count == 1){
        TokenTxKernel* kernel = [self.body.token_kernels objectAtIndex:0];
        kernel.excess = excess;
        kernel.excess_sig = sig;
        if ([kernel verify]){
            return YES;
        }
    }
    
    return NO;
}

-(NSData*)computePayloadForHash:(BOOL)yesOrNo{
    NSMutableData* data = [NSMutableData new];
    [data appendData:self.offset];
    [data appendData:[self.body computePayloadForHash:yesOrNo]];
    return data;
}

-(void)sortTx{
    NSComparisonResult (^sortBlock)(TxBaseObject*  _Nonnull obj1, TxBaseObject*  _Nonnull obj2) = ^NSComparisonResult(TxBaseObject*  _Nonnull obj1, TxBaseObject*  _Nonnull obj2) {
        NSData* hash1 = [obj1 blake2bHash];
        NSData* hash2 = [obj2 blake2bHash];
        for (NSUInteger i=0; i<32; i++){
            uint8_t byte1 = ((uint8_t*)hash1.bytes)[i];
            uint8_t byte2 = ((uint8_t*)hash2.bytes)[i];
            if (byte1 > byte2){
                return NSOrderedDescending;
            }
            else if(byte1 < byte2){
                return NSOrderedAscending;
            }
            else{
                continue;
            }
        }
        DDLogError(@"-----hash value can not be equal, obj1=%@, obj2=%@", obj1, obj2);
        assert(false);
        return NSOrderedSame;
    };
    [self.body.inputs sortUsingComparator:sortBlock];
    [self.body.token_inputs sortUsingComparator:sortBlock];
    [self.body.outputs sortUsingComparator:sortBlock];
    [self.body.token_outputs sortUsingComparator:sortBlock];
    [self.body.kernels sortUsingComparator:sortBlock];
    [self.body.token_kernels sortUsingComparator:sortBlock];
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
        //self.sig_data = compactData;
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


@implementation ExportPaymentInfo

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    if (!self.token_type) {
        dic[@"token_type"] = [NSNull null];
    }
    
    return YES;
}

@end

