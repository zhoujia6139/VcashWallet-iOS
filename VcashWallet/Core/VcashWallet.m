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
#import "VcashTxLog.h"

#define DEFAULT_BASE_FEE 1000000

static VcashWallet* walletInstance = nil;

@interface VcashWallet()

@property (strong, nonatomic)VcashKeyChain* mKeyChain;

@end

@implementation VcashWallet
{
    uint64_t _curChainHeight;
    NSString* _userId;
}

+(void)createWalletWithKeyChain:(VcashKeyChain*)keychain{
    if (keychain && !walletInstance){
        walletInstance = [[self alloc] init];
        walletInstance.mKeyChain = keychain;
        VcashWalletInfo* baseInfo = [[VcashDataManager shareInstance] loadWalletInfo];
        if (baseInfo){
            walletInstance->_curKeyPath = [[VcashKeychainPath alloc] initWithPathstr:baseInfo.curKeyPath];
            walletInstance->_curChainHeight = baseInfo.curHeight;
            walletInstance->_curTxLogId = baseInfo.curTxLogId;
        }
        [walletInstance reloadOutputInfo];
    }
}

+ (instancetype)shareInstance{
    return walletInstance;
}

-(NSString*)userId{
    if (!_userId){
        VcashSecretKey* key = [self.mKeyChain deriveKey:0 andKeypath:[[VcashKeychainPath alloc] initWithDepth:4 d0:0 d1:0 d2:0 d3:0]];
        _userId = BTCHexFromData(key.data);
    }
    return _userId;
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
    [self syncOutputInfo];
}

-(void)addNewTxChangeOutput:(VcashOutput*)output{
    NSMutableArray* arr = [[NSMutableArray alloc] initWithArray:self->_outputs];
    [arr addObject:output];
    self->_outputs = arr;
}

-(void)syncOutputInfo{
    [[VcashDataManager shareInstance] saveOutputData:self.outputs];
}

-(void)reloadOutputInfo{
    walletInstance->_outputs = [[VcashDataManager shareInstance] getActiveOutputData];
}

-(uint64_t)curChainHeight{
    uint64_t height = [[NodeApi shareInstance] getChainHeight];
    if (height > self->_curChainHeight){
        self->_curChainHeight = height;
        [self saveBaseInfo];
    }
    return self->_curChainHeight;
}

-(WalletBalanceInfo*)getWalletBalanceInfo{
    uint64_t total = 0;
    uint64_t locked = 0;
    uint64_t unconfirmed = 0;
    uint64_t spendable = 0;
    for (VcashOutput* output in self.outputs){
        switch (output.status) {
            case Unconfirmed:{
                total += output.value;
                unconfirmed += output.value;
                break;
            }
            case Unspent:{
                total += output.value;
                spendable += output.value;
                break;
            }
                
            case Locked:{
                locked += output.value;
                break;
            }
                
            default:
                break;
        }
    }
    
    WalletBalanceInfo* info = [WalletBalanceInfo new];
    info.total = total;
    info.spendable = spendable;
    info.locked = locked;
    info.unconfirmed = unconfirmed;
    return info;
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
    
    //2 fill txLog and slate
    VcashSlate* slate = [VcashSlate new];
    slate.num_participants = 2;
    slate.amount = amount;
    slate.height = self.curChainHeight;
    slate.lock_height = self.curChainHeight;
    slate.fee = actualFee;
    
    VcashTxLog* txLog = [VcashTxLog new];
    txLog.tx_id = [[VcashWallet shareInstance] getNextLogId];
    txLog.tx_slate_id = slate.uuid;
    txLog.tx_type = TxSent;
    txLog.create_time = [[NSDate date] timeIntervalSince1970];
    txLog.fee = slate.fee;
    txLog.amount_credited = change;
    txLog.amount_debited = total;
    txLog.is_confirmed = NO;
    slate.txLog = txLog;
    
    VcashSecretKey* blind = [slate addTxElement:self.outputs change:change];
    if (!blind){
        DDLogError(@"--------sender addTxElement failed");
        return nil;
    }
    
    //3 construct sender Context
    VcashContext* context = [[VcashContext alloc] init];
    context.sec_key = blind;
    context.slate_id = slate.uuid;
    slate.context = context;
    
    //4 sender fill round 1
    if (![slate fillRound1:context participantId:0 andMessage:nil]){
        DDLogError(@"--------sender fillRound1 failed");
        return nil;
    }

    return slate;
}

-(BOOL)receiveTransaction:(VcashSlate*)slate{
    //5, fill slate with receiver output
    VcashTxLog* txLog = [VcashTxLog new];
    txLog.tx_id = [[VcashWallet shareInstance] getNextLogId];
    txLog.tx_slate_id = slate.uuid;
    txLog.tx_type = TxReceived;
    txLog.create_time = [[NSDate date] timeIntervalSince1970];
    //txLog.fee = slate.fee;
    txLog.amount_credited = slate.amount;
    txLog.amount_debited = 0;
    txLog.is_confirmed = NO;
    slate.txLog = txLog;
    
    VcashSecretKey* blind = [slate addReceiverTxOutput];
    if (!blind){
        DDLogError(@"--------receiver addReceiverTxOutput failed");
        return NO;
    }
    
    //6, construct receiver Context
    VcashContext* context = [[VcashContext alloc] init];
    context.sec_key = blind;
    context.slate_id = slate.uuid;
    slate.context = context;
    
    //7, receiver fill round 1
    if (![slate fillRound1:context participantId:1 andMessage:nil]){
        DDLogError(@"--------receiver fillRound1 failed");
        return NO;
    }
    
    //8, receiver fill round 2
    if (![slate fillRound2:context participantId:1]){
        DDLogError(@"--------receiver fillRound2 failed");
        return NO;
    }
    NSString* result = [slate modelToJSONString];
    NSLog(@"---------:%@", result);
    
    return YES;
}

-(BOOL)finalizeTransaction:(VcashSlate*)slate{
    VcashContext* context = slate.context;
    
    //9, sender fill round 2
    if (![slate fillRound2:context participantId:0])
    {
        DDLogError(@"--------sender fillRound2 failed");
        return NO;
    }
    
    //10, create group signature
    VcashSignature* groupSig = [slate finalizeSignature];
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
    if (self.curKeyPath){
        self->_curKeyPath = [self.curKeyPath nextPath];
        [self saveBaseInfo];
    }
    else{
        self->_curKeyPath = [[VcashKeychainPath alloc] initWithDepth:3 d0:0 d1:0 d2:0 d3:0];
    }

    return self.curKeyPath;
}

-(uint32_t)getNextLogId{
    self->_curTxLogId += 1;
    [self saveBaseInfo];
    return self.curTxLogId;
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
    info.curTxLogId = self.curTxLogId;
    
    [[VcashDataManager shareInstance] saveWalletInfo:info];
}

@end


@implementation WalletBalanceInfo


@end
