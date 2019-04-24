//
//  VcashSlate.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashSlate.h"
#import "VcashWallet.h"
#import "VcashKeychainPath.h"
#import "VcashContext.h"
#import "VcashSecp256k1.h"
#import "VcashTypes.h"

@implementation VcashSlate

-(id)init{
    self = [super init];
    if (self){
        _uuid = BTCHexFromData(BTCRandomDataWithLength(16));
        _version = 1;
        _tx = [VcashTransaction new];
        _participant_data = [NSMutableArray new];
    }
    return self;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"uuid":@"id",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"participant_data" : [ParticipantData class]};
}

-(VcashSecretKey*)addTxElement:(NSArray*)outputs change:(uint64_t)change{
    VcashTransaction* temptx = self.tx;
    TxKernel* txKernel = [TxKernel new];
    NSMutableArray<NSData*>* positiveArr = [NSMutableArray new];
    NSMutableArray<NSData*>* negativeArr = [NSMutableArray new];
    
    //1,fee
    txKernel.fee = self.fee;
    
    //2,input
    for (VcashOutput* item in outputs){
        VcashKeychainPath* keypath = [[VcashKeychainPath alloc] initWithPathstr:item.keyPath];
        NSData*commitment = [[VcashWallet shareInstance].mKeyChain createCommitment:item.value andKeypath:keypath];
        Input* input = [Input new];
        input.commit = commitment;
        input.features = (item.is_coinbase?OutputFeatureCoinbase:OutputFeaturePlain);
        
        [temptx.body.inputs addObject:input];
        VcashSecretKey* secKey = [[VcashWallet shareInstance].mKeyChain deriveKey:item.value andKeypath:keypath];
        [negativeArr addObject:secKey.data];
    }
    
    //output
    if (change > 0){
        VcashKeychainPath* keypath = [[VcashWallet shareInstance] nextChild];
        NSData*commitment = [[VcashWallet shareInstance].mKeyChain createCommitment:change andKeypath:keypath];
        NSData*proof = [[VcashWallet shareInstance].mKeyChain createRangeProof:change withKeyPath:keypath];
        Output* output = [Output new];
        output.features = OutputFeaturePlain;
        output.commit = commitment;
        output.proof = proof;
        
        [temptx.body.outputs addObject:output];
        VcashSecretKey* secKey = [[VcashWallet shareInstance].mKeyChain deriveKey:change andKeypath:keypath];
        [positiveArr addObject:secKey.data];
    }
    
    //lockheight
    [txKernel setLock_height:self.lock_height];
    
    [temptx.body.kernels addObject:txKernel];
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    VcashSecretKey* blind = [secp blindSumWithPositiveArr:positiveArr andNegative:negativeArr];
    return blind;
}

-(BOOL)fillRound1:(VcashContext*)context participantId:(NSUInteger)participant_id andMessage:(NSString*)message{
    if (!self.tx.offset){
        [self generateOffset:context];
    }
    [self addParticipantInfo:context participantId:participant_id andMessage:message];
    return YES;
}

#pragma private
-(void)generateOffset:(VcashContext*)context{
    self.tx.offset = [VcashSecretKey nounceKey].data;
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    NSMutableArray<NSData*>* positiveArr = [NSMutableArray new];
    NSMutableArray<NSData*>* negativeArr = [NSMutableArray new];
    [positiveArr addObject:context.sec_key.data];
    [negativeArr addObject:self.tx.offset];
    VcashSecretKey* blind = [secp blindSumWithPositiveArr:positiveArr andNegative:negativeArr];
    context.sec_key = blind;
}

-(void)addParticipantInfo:(VcashContext*)context participantId:(NSUInteger)participant_id andMessage:(NSString*)message{
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    NSData* pub_key = [secp getPubkeyFormSecretKey:context.sec_key];
    NSData* pub_nonce = [secp getPubkeyFormSecretKey:context.sec_nounce];
    
    ParticipantData* partiData = [ParticipantData new];
    partiData.pId = participant_id;
    partiData.public_nonce = pub_nonce;
    partiData.public_blind_excess = pub_key;
    partiData.message = message;
    
    [self.participant_data addObject:partiData];
}

@end

@implementation ParticipantData

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"pId":@"id",
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    
    self.public_blind_excess = [PublicTool getDataFromArray:dic[@"public_blind_excess"]];
    self.public_nonce = [PublicTool getDataFromArray:dic[@"public_nonce"]];
    self.part_sig = [PublicTool getDataFromArray:dic[@"part_sig"]];
    self.message_sig = [PublicTool getDataFromArray:dic[@"message_sig"]];
    
    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    if (self.public_blind_excess){
        dic[@"public_blind_excess"] = [PublicTool getArrFromData:self.public_blind_excess];
    }
    if (self.public_nonce){
        dic[@"public_nonce"] = [PublicTool getArrFromData:self.public_nonce];
    }
    if (self.part_sig){
        dic[@"part_sig"] = [PublicTool getArrFromData:self.part_sig];
    }
    if (self.public_blind_excess){
        dic[@"message_sig"] = [PublicTool getArrFromData:self.message_sig];
    }
    
    return YES;
}

@end
