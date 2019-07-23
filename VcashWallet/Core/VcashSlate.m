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
#include "uuid4.h"

@implementation VcashSlate

-(id)init{
    self = [super init];
    if (self){
        char buf[UUID4_LEN];
        uuid4_init();
        uuid4_generate(buf);
        _uuid = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
        _version_info = [VersionCompatInfo createVersionInfo];
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

+ (NSArray *)modelPropertyBlacklist {
    return @[@"txLog", @"lockOutputsFn", @"createNewOutputsFn", @"context"];
}

-(VcashSecretKey*)addTxElement:(NSArray*)outputs change:(uint64_t)change{
    VcashTransaction* temptx = self.tx;
    TxKernel* txKernel = [TxKernel new];
    NSMutableArray<NSData*>* positiveArr = [NSMutableArray new];
    NSMutableArray<NSData*>* negativeArr = [NSMutableArray new];
    
    //1,fee
    txKernel.fee = self.fee;
    
    //2,input
    NSMutableArray* lockOutput = [NSMutableArray new];
    for (VcashOutput* item in outputs){
        if (item.status != Unspent){
            continue;
        }
        VcashKeychainPath* keypath = [[VcashKeychainPath alloc] initWithPathstr:item.keyPath];
        NSData*commitment = [[VcashWallet shareInstance].mKeyChain createCommitment:item.value andKeypath:keypath andSwitchType:SwitchCommitmentTypeRegular];
        Input* input = [Input new];
        input.commit = commitment;
        input.features = (item.is_coinbase?OutputFeatureCoinbase:OutputFeaturePlain);
        
        [temptx.body.inputs addObject:input];
        VcashSecretKey* secKey = [[VcashWallet shareInstance].mKeyChain deriveKey:item.value andKeypath:keypath andSwitchType:SwitchCommitmentTypeRegular];
        [negativeArr addObject:secKey.data];
        
        [lockOutput addObject:item];
        [self.txLog appendInput:item.commitment];
    }
    self.lockOutputsFn = ^{
        for (VcashOutput* item in lockOutput){
            item.status = Locked;
        }
    };
    
    //output
    if (change > 0){
        VcashSecretKey* secKey = [self createTxOutputWithAmount:change];
        [positiveArr addObject:secKey.data];
    }
    
    //lockheight
    [txKernel setLock_height:self.lock_height];
    
    [temptx.body.kernels addObject:txKernel];
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    VcashSecretKey* blind = [secp blindSumWithPositiveArr:positiveArr andNegative:negativeArr];
    return blind;
}

-(VcashSecretKey*)addReceiverTxOutput{
    VcashSecretKey* secKey = [self createTxOutputWithAmount:self.amount];
    [self.tx sortTx];
    return secKey;
}

-(BOOL)fillRound1:(VcashContext*)context participantId:(NSUInteger)participant_id andMessage:(NSString*)message{
    if (!self.tx.offset){
        [self generateOffset:context];
    }
    [self addParticipantInfo:context participantId:participant_id andMessage:message];
    return YES;
}

-(BOOL)fillRound2:(VcashContext*)context participantId:(NSUInteger)participant_id{
    //TODO check fee?
    
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    
    NSMutableArray* pubNonceArr = [NSMutableArray new];
    NSMutableArray* pubBlindArr = [NSMutableArray new];
    for (ParticipantData* item in self.participant_data) {
        [pubNonceArr addObject:item.public_nonce];
        [pubBlindArr addObject:item.public_blind_excess];
    }
    NSData* nonceSum = [secp combinationPubkey:pubNonceArr];
    NSData* keySum = [secp combinationPubkey:pubBlindArr];
    NSData* msgData = [self createMsgToSign];
    if (!nonceSum || !keySum || !msgData){
        return NO;
    }
    
    //1, verify part sig
    for (ParticipantData* item in self.participant_data){
        if (item.part_sig){
            if (![secp verifySingleSignature:item.part_sig pubkey:item.public_blind_excess nonceSum:nonceSum pubkeySum:keySum andMsgData:msgData]){
                DDLogError(@"----verifySingleSignature failed! pId = %d", item.pId);
                return NO;
            }
        }
    }
    
    //2, calcluate part sig
    VcashSignature* sig = [secp calculateSingleSignature:context.sec_key.data secNonce:context.sec_nounce.data nonceSum:nonceSum pubkeySum:keySum andMsgData:msgData];
    if (!sig){
        return NO;
    }
    
    ParticipantData* participantData = nil;
    for (ParticipantData* item in self.participant_data){
        if (item.pId == participant_id){
            participantData = item;
        }
    }
    participantData.part_sig = sig;
    
    return YES;
}

-(VcashSignature*)finalizeSignature{
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    
    NSMutableArray* pubNonceArr = [NSMutableArray new];
    NSMutableArray* pubBlindArr = [NSMutableArray new];
    NSMutableArray* sigsArr = [NSMutableArray new];
    for (ParticipantData* item in self.participant_data) {
        [pubNonceArr addObject:item.public_nonce];
        [pubBlindArr addObject:item.public_blind_excess];
        [sigsArr addObject:item.part_sig];
    }
    NSData* nonceSum = [secp combinationPubkey:pubNonceArr];
    NSData* keySum = [secp combinationPubkey:pubBlindArr];
    
    //calcluate group signature
    VcashSignature* finalSig = [secp combinationSignature:sigsArr nonceSum:nonceSum];
    NSData* msgData = [self createMsgToSign];
    if (finalSig && msgData){
        BOOL yesOrNO = [secp verifySingleSignature:finalSig pubkey:keySum nonceSum:nil pubkeySum:keySum andMsgData:msgData];
        if (yesOrNO){
            return finalSig;
        }
    }
    
    return nil;
}

-(BOOL)finalizeTx:(VcashSignature*)finalSig{
    //TODO check fee?
    
    NSData* final_excess = [self.tx calculateFinalExcess];
    if ([self.tx setTxExcess:final_excess andTxSig:finalSig]){
        return YES;
    }
    
    return NO;
}

#pragma private
-(VcashSecretKey*)createTxOutputWithAmount:(uint64_t)amount{
    VcashTransaction* temptx = self.tx;
    VcashKeychainPath* keypath = [[VcashWallet shareInstance] nextChild];
    NSData*commitment = [[VcashWallet shareInstance].mKeyChain createCommitment:amount andKeypath:keypath andSwitchType:SwitchCommitmentTypeRegular];
    NSData*proof = [[VcashWallet shareInstance].mKeyChain createRangeProof:amount withKeyPath:keypath];
    Output* output = [Output new];
    output.features = OutputFeaturePlain;
    output.commit = commitment;
    output.proof = proof;
    
    [temptx.body.outputs addObject:output];
    VcashSecretKey* secKey = [[VcashWallet shareInstance].mKeyChain deriveKey:amount andKeypath:keypath andSwitchType:SwitchCommitmentTypeRegular];
    
    __weak typeof (self) weak_self = self;
    self.createNewOutputsFn = ^{
        __strong typeof (weak_self) strong_self = weak_self;
        VcashOutput* output = [VcashOutput new];
        output.commitment = BTCHexFromData(commitment);
        output.keyPath = keypath.pathStr;
        output.value = amount;
        output.height = strong_self.height;
        output.lock_height = 0;
        output.is_coinbase = NO;
        output.status = Unconfirmed;
        output.tx_log_id = strong_self.txLog.tx_id;
        [strong_self.txLog appendOutput:output.commitment];
        
        [[VcashWallet shareInstance] addNewTxChangeOutput:output];
    };
    
    return secKey;
}

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

-(NSData*)createMsgToSign{
    TxKernel* kernel = [self.tx.body.kernels firstObject];
    return [kernel kernelMsgToSign];
}

-(BOOL)isValidForReceive{
    if (self.participant_data.count != 1){
        return NO;
    }
    
    if (self.tx.body.inputs.count == 0 || self.tx.body.kernels.count == 0){
        return NO;
    }
    
    return YES;
}

-(BOOL)isValidForFinalize{
    if (self.participant_data.count != 2){
        return NO;
    }
    
    if (self.tx.body.inputs.count == 0 || self.tx.body.kernels.count == 0){
        return NO;
    }
    
    return YES;
}

@end

@implementation VersionCompatInfo

+(instancetype)createVersionInfo{
    VersionCompatInfo* info = [VersionCompatInfo new];
    info.version= 2;
    info.orig_version = 2;
    info.block_header_version = 1;
    return info;
}

@end

@implementation ParticipantData

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"pId":@"id",
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    if ([dic[@"public_blind_excess"] isKindOfClass:[NSString class]]){
        NSData* compressBlind_excess = BTCDataFromHex(dic[@"public_blind_excess"]);
        self.public_blind_excess = [secp pubkeyFromCompressedKey:compressBlind_excess];
        
    }
    
    if ([dic[@"public_nonce"] isKindOfClass:[NSString class]]){
        NSData* compressNounce = BTCDataFromHex(dic[@"public_nonce"]);
        self.public_nonce = [secp pubkeyFromCompressedKey:compressNounce];
    }
    
    if ([dic[@"part_sig"] isKindOfClass:[NSString class]]){
        NSData* compactPartSig = BTCDataFromHex(dic[@"part_sig"]);
        self.part_sig = [[VcashSignature alloc] initWithCompactData:compactPartSig];
    }

    if ([dic[@"message_sig"] isKindOfClass:[NSString class]]){
        NSData* compactMsgSig = BTCDataFromHex(dic[@"message_sig"]);
        self.message_sig = [[VcashSignature alloc] initWithCompactData:compactMsgSig];
    }
    
    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    
    if (self.public_blind_excess){
        NSData* compressed = [secp getCompressedPubkey:self.public_blind_excess];
        dic[@"public_blind_excess"] = BTCHexFromData(compressed);
    }
    else{
        dic[@"public_blind_excess"] = [NSNull null];
    }

    if (self.public_nonce){
        NSData* noncecompressed = [secp getCompressedPubkey:self.public_nonce];
        dic[@"public_nonce"] = BTCHexFromData(noncecompressed);
    }
    else{
        dic[@"public_nonce"] = [NSNull null];
    }
    
    if (self.part_sig) {
        NSData* compactPartSig = [self.part_sig getCompactData];
        dic[@"part_sig"] = BTCHexFromData(compactPartSig);
        //dic[@"part_sig"] = BTCHexFromData(self.part_sig.sig_data);
    }
    else{
        dic[@"part_sig"] = [NSNull null];
    }
    
    if (self.message_sig){
        NSData* messageSig = [self.message_sig getCompactData];
        dic[@"message_sig"] = BTCHexFromData(messageSig);
    }
    else{
        dic[@"message_sig"] = [NSNull null];
    }
    
    if (!self.message){
        dic[@"message"] = [NSNull null];
    }
    
    return YES;
}

@end
