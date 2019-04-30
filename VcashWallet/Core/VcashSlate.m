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

+ (NSArray *)modelPropertyBlacklist {
    return @[@"txLog", @"lockOutputsFn", @"createNewOutputsFn", @"context"];
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSString* text = dic[@"id"];
    self.uuid = [text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    //self.uuid = text;
    
    return YES;
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
        NSData*commitment = [[VcashWallet shareInstance].mKeyChain createCommitment:item.value andKeypath:keypath];
        Input* input = [Input new];
        input.commit = commitment;
        input.features = (item.is_coinbase?OutputFeatureCoinbase:OutputFeaturePlain);
        
        [temptx.body.inputs addObject:input];
        VcashSecretKey* secKey = [[VcashWallet shareInstance].mKeyChain deriveKey:item.value andKeypath:keypath];
        [negativeArr addObject:secKey.data];
        
        [lockOutput addObject:item];
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
    NSLog(@"------blind=%@", BTCHexFromData(blind.data));
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
            DDLogWarn(@"keySum=%@, nonceSum=%@, msgData=%@, item.part_sig=%@, pubkey=%@", BTCHexFromData(keySum), BTCHexFromData(nonceSum), BTCHexFromData(msgData), BTCHexFromData(item.part_sig.sig_data), BTCHexFromData(item.public_blind_excess));
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
    NSData*commitment = [[VcashWallet shareInstance].mKeyChain createCommitment:amount andKeypath:keypath];
    NSData*proof = [[VcashWallet shareInstance].mKeyChain createRangeProof:amount withKeyPath:keypath];
    Output* output = [Output new];
    output.features = OutputFeaturePlain;
    output.commit = commitment;
    output.proof = proof;
    
    [temptx.body.outputs addObject:output];
    VcashSecretKey* secKey = [[VcashWallet shareInstance].mKeyChain deriveKey:amount andKeypath:keypath];
    
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
        
        [[VcashWallet shareInstance] addNewTxChangeOutput:output];
        [[VcashWallet shareInstance] syncOutputInfo];
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



@end

@implementation ParticipantData

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"pId":@"id",
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    NSData* compressBlind_excess = [PublicTool getDataFromArray:dic[@"public_blind_excess"]];
    self.public_blind_excess = [secp pubkeyFromCompressedKey:compressBlind_excess];
    
    NSData* compressNounce = [PublicTool getDataFromArray:dic[@"public_nonce"]];
    self.public_nonce = [secp pubkeyFromCompressedKey:compressNounce];
    
    NSData* compactPartSig = [PublicTool getDataFromArray:dic[@"part_sig"]];
    self.part_sig = [[VcashSignature alloc] initWithCompactData:compactPartSig];
    
    NSData* compactMsgSig = [PublicTool getDataFromArray:dic[@"message_sig"]];
    self.message_sig = [[VcashSignature alloc] initWithCompactData:compactMsgSig];
    
    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    
    NSData* compressed = [secp getCompressedPubkey:self.public_blind_excess];
    dic[@"public_blind_excess"] = [PublicTool getArrFromData:compressed];

    NSData* noncecompressed = [secp getCompressedPubkey:self.public_nonce];
    dic[@"public_nonce"] = [PublicTool getArrFromData:noncecompressed];
    
    NSData* compactPartSig = [self.part_sig getCompactData];
    dic[@"part_sig"] = [PublicTool getArrFromData:compactPartSig];
    
    NSData* messageSig = [self.message_sig getCompactData];
    dic[@"message_sig"] = [PublicTool getArrFromData:messageSig];
    
    return YES;
}

@end
