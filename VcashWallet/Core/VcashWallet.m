//
//  VcashWallet.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/20.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashWallet.h"
#import "VcashContext.h"
#import "NodeApi.h"
#import "VcashDataManager.h"

#define DEFAULT_BASE_FEE 1000000

static VcashWallet* walletInstance = nil;

static VcashContext* testContext = nil;

@interface VcashWallet()

@property (strong, nonatomic)VcashKeyChain* mKeyChain;

@end

@implementation VcashWallet
{
    uint64_t _curChainHeight;
}

+(void)createWalletWithKeyChain:(VcashKeyChain*)keychain{
    if (keychain && !walletInstance){
        walletInstance = [[self alloc] init];
        walletInstance.mKeyChain = keychain;
        walletInstance->_outputs = [[VcashDataManager shareInstance] getActiveOutputData];
        VcashWalletInfo* baseInfo = [[VcashDataManager shareInstance] loadWalletInfo];
        walletInstance->_curKeyPath = [[VcashKeychainPath alloc] initWithPathstr:baseInfo.curKeyPath];
        walletInstance->_curChainHeight = baseInfo.curHeight;
    }
}

+ (instancetype)shareInstance{
    return walletInstance;
}

-(void)setChainOutputs:(NSArray*)arr{
    self->_outputs = arr;
    NSString* maxKeypath = @"";
    for (VcashOutput* item in arr){
        if ([item.keyPath compare:maxKeypath options:NSNumericSearch] == NSOrderedDescending){
            maxKeypath = item.keyPath;
        }
    }
    self->_curKeyPath = [[VcashKeychainPath alloc] initWithPathstr:maxKeypath];
    [self saveBaseInfo];
    [[VcashDataManager shareInstance] saveOutputData:arr];
}

-(uint64_t)curChainHeight{
    uint64_t height = [[NodeApi shareInstance] getChainHeight];
    if (height > self->_curChainHeight){
        self->_curChainHeight = height;
        [self saveBaseInfo];
    }
    return self->_curChainHeight;
}

-(VcashOutput*)identifyUtxoOutput:(NodeOutput*)nodeOutput{
    NSData* commit = BTCDataFromHex(nodeOutput.commit);
    NSData* proof = BTCDataFromHex(nodeOutput.proof);
    VcashProofInfo* info = [self.mKeyChain rewindProof:commit withProof:proof];
    if (info.isSuc){
        VcashOutput* output = [VcashOutput new];
        output.commitment = nodeOutput.commit;
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

-(VcashSlate*)sendTransaction:(uint64_t)amount andFee:(uint64_t)fee withComplete:(RequestCompleteBlock)block{
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
    amount_with_fee = amount + actualFee;
    uint64_t change = total - amount_with_fee;
    
    //2 fill slate
    VcashSlate* slate = [VcashSlate new];
    slate.num_participants = 2;
    slate.amount = amount;
    slate.height = self.curChainHeight;
    slate.lock_height = self.curChainHeight;
    slate.fee = actualFee;
    VcashSecretKey* blind = [slate addTxElement:self.outputs change:change];
    if (!blind){
        DDLogError(@"--------sender addTxElement failed");
        return nil;
    }
    
    //3 construct sender Context
    VcashContext* context = [[VcashContext alloc] init];
    context.sec_key = blind;
    
    //4 sender fill round 1
    if (![slate fillRound1:context participantId:0 andMessage:nil]){
        DDLogError(@"--------sender fillRound1 failed");
        return nil;
    }
    NSString* result = [slate modelToJSONString];
    NSLog(@"---------:%@", result);
    testContext = context;
    return slate;
}

-(VcashSlate*)receiveTransaction:(VcashSlate*)slate{
    //5, fill slate with receiver output
    VcashSecretKey* blind = [slate addReceiverTxOutput];
    if (!blind){
        DDLogError(@"--------receiver addReceiverTxOutput failed");
        return nil;
    }
    
    //6, construct receiver Context
    VcashContext* context = [[VcashContext alloc] init];
    context.sec_key = blind;
    
    //7, receiver fill round 1
    if (![slate fillRound1:context participantId:1 andMessage:nil]){
        DDLogError(@"--------receiver fillRound1 failed");
        return nil;
    }
    
    //8, receiver fill round 2
    if (![slate fillRound2:context participantId:1]){
        DDLogError(@"--------receiver fillRound2 failed");
        return nil;
    }
    NSString* result = [slate modelToJSONString];
    NSLog(@"---------:%@", result);
    
    return slate;
}

-(BOOL)finalizeTransaction:(VcashSlate*)slate{
    VcashContext* context = testContext;
    
    //9, sender fill round 2
    if (![slate fillRound2:context participantId:0])
    {
        DDLogError(@"--------sender fillRound2 failed");
        return NO;
    }
    
    //10, create group signature
    NSData* groupSig = [slate finalizeSignature];
    if (!groupSig){
        DDLogError(@"--------sender create group signature failed");
        return NO;
    }
    
    if (![slate finalizeTx:groupSig]){
        DDLogError(@"--------sender finalize tx failed");
        return NO;
    }
    NSString* result = [slate modelToJSONString];
    NSLog(@"---------:%@", result);
    return YES;
}

-(VcashKeychainPath*)nextChild{
    self->_curKeyPath = [self.curKeyPath nextPath];
    [self saveBaseInfo];
    return self.curKeyPath;
}

#pragma private
-(uint64_t)calcuteFee:(NSInteger)inputCount withOutputCount:(NSInteger)outputCount{
    NSInteger tx_weight = outputCount * 4 + 1 - inputCount;
    tx_weight = (tx_weight>1?tx_weight:1);
    
    return DEFAULT_BASE_FEE*tx_weight;
}

-(void)saveBaseInfo{
    VcashWalletInfo* info = [VcashWalletInfo new];
    info.curKeyPath = self.curKeyPath.pathStr;
    info.curHeight = self.curChainHeight;
    
    [[VcashDataManager shareInstance] saveWalletInfo:info];
}

@end
