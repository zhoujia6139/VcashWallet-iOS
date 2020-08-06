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
#include "blake2.h"
#import "payment-proof-lib.h"

#define DEFAULT_BASE_FEE 1000000

static VcashWallet* walletInstance = nil;

@interface VcashWallet()

@property (strong, nonatomic)VcashKeyChain* mKeyChain;

@end

@implementation VcashWallet
{
    uint64_t _curChainHeight;
    VcashKeychainPath* _curKeyPath;
    uint32_t _curTxLogId;
    NSString* _userId;
    NSArray* _tokenOutputs;
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
        [walletInstance reloadTokenOutputInfo];
    }
}

+ (instancetype)shareInstance{
    return walletInstance;
}

-(NSString*)userId{
    bool isTestNet = false;
#ifdef isInTestNet
    isTestNet = true;
#endif
    if (!_userId){
        NSData* sec_key = [[VcashWallet shareInstance] getPaymentProofKey];
        NSString* sec_str = BTCHexFromData(sec_key);
        const char* address_str = slate_address([sec_str UTF8String], isTestNet);
        NSString* address_ret = [NSString stringWithUTF8String:address_str];
        c_str_free(address_str);
        return address_ret;
    }
    return _userId;
}

-(NSString*)getSignerKey{
//    BTCKey* key = [self.mKeyChain deriveBTCKeyWithKeypath:[[VcashKeychainPath alloc] initWithDepth:4 d0:0 d1:0 d2:0 d3:0]];
//    return key.privateKey;
    NSData* data = [self getPaymentProofKey];
    return BTCHexFromData(data);
}

-(NSData*)getPaymentProofKey{

    VcashKeychainPath* keyPath = [[VcashKeychainPath alloc] initWithDepth:3 d0:0 d1:1 d2:0 d3:0 ];
    VcashSecretKey* sec_key = [self.mKeyChain deriveKey:0 andKeypath:keyPath andSwitchType:SwitchCommitmentTypeNone];
    uint8_t ret[SECRET_KEY_SIZE];
    if( blake2b( ret, sec_key.data.bytes, nil, SECRET_KEY_SIZE, sec_key.data.length, 0 ) < 0)
    {
        return nil;
    }
    NSData* keydata = [NSData dataWithBytes:ret length:SECRET_KEY_SIZE];
    return keydata;
}

-(void)setChainOutputs:(NSArray*)arr{
    self->_outputs = arr;
    NSString* maxKeypath = @"";
    if (self->_curKeyPath){
        maxKeypath = [self->_curKeyPath pathStr];
    }
    for (VcashOutput* item in arr){
        if ([item.keyPath compare:maxKeypath options:NSNumericSearch] == NSOrderedDescending){
            maxKeypath = item.keyPath;
        }
    }
    self->_curKeyPath = [[VcashKeychainPath alloc] initWithPathstr:maxKeypath];
    [self saveBaseInfo];
    [self syncOutputInfo];
}

-(void)setChainTokenOutputs:(NSArray*)arr{
    self->_tokenOutputs = arr;
    NSString* maxKeypath = @"";
    if (self->_curKeyPath){
        maxKeypath = [self->_curKeyPath pathStr];
    }
    for (VcashTokenOutput* item in arr){
        if ([item.keyPath compare:maxKeypath options:NSNumericSearch] == NSOrderedDescending){
            maxKeypath = item.keyPath;
        }
    }
    self->_curKeyPath = [[VcashKeychainPath alloc] initWithPathstr:maxKeypath];
    [self saveBaseInfo];
    [self syncTokenOutputInfo];
}

-(void)addNewTxChangeOutput:(VcashOutput*)output{
    NSMutableArray* arr = [[NSMutableArray alloc] initWithArray:self->_outputs];
    [arr addObject:output];
    self->_outputs = arr;
}

-(void)addNewTokenTxChangeOutput:(VcashTokenOutput*)output{
    NSMutableArray* arr = [[NSMutableArray alloc] initWithArray:self->_tokenOutputs];
    [arr addObject:output];
    self->_tokenOutputs = arr;
    [self tokenOutputToDic];
}

-(void)syncOutputInfo{
    NSMutableArray* outputs = [NSMutableArray new];
    for (VcashOutput* item in self.outputs){
        if (item.status == Spent){
            DDLogWarn(@"Output commit:%@ has been spend, remove from wallet", item.commitment);
        }
        else{
            [outputs addObject:item];
        }
    }
    self->_outputs = outputs;
    [[VcashDataManager shareInstance] saveOutputData:self.outputs];
}

-(void)syncTokenOutputInfo{
    NSMutableArray* tokenOutputs = [NSMutableArray new];
    for (VcashTokenOutput* item in self->_tokenOutputs){
        if (item.status == Spent){
            DDLogWarn(@"Token Output commit:%@ has been spend, remove from wallet", item.commitment);
        }
        else{
            [tokenOutputs addObject:item];
        }
    }
    self->_tokenOutputs = tokenOutputs;
    [self tokenOutputToDic];
    [[VcashDataManager shareInstance] saveTokenOutputData:self->_tokenOutputs];
}

-(void)reloadOutputInfo{
    walletInstance->_outputs = [[VcashDataManager shareInstance] getActiveOutputData];
}

-(void)reloadTokenOutputInfo{
    walletInstance->_tokenOutputs = [[VcashDataManager shareInstance] getActiveTokenOutputData];
    [self tokenOutputToDic];
}

-(VcashOutput*)findOutputByCommit:(NSString*)commit{
    for (VcashOutput* output in self.outputs) {
        if ([output.commitment isEqualToString:commit]) {
            return output;
        }
    }
    
    return nil;
}

-(VcashTokenOutput*)findTokenOutputByCommit:(NSString*)commit{
    for (VcashTokenOutput* output in self->_tokenOutputs) {
        if ([output.commitment isEqualToString:commit]) {
            return output;
        }
    }
    
    return nil;
}

-(uint64_t)curChainHeight{
    uint64_t height = [[NodeApi shareInstance] getChainHeightWithComplete:^(BOOL yesOrNo, NodeChainInfo* info) {
        if (yesOrNo && info.height > self->_curChainHeight){
            self->_curChainHeight = info.height;
            [self saveBaseInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:kWalletChainHeightChange object:nil];
        }
    }];
    self->_curChainHeight = height>self->_curChainHeight?height:self->_curChainHeight;

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
                if ([output isSpendable]){
                    spendable += output.value;
                }
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

-(WalletBalanceInfo*)getWalletTokenBalanceInfo:(NSString*)tokenType {
    uint64_t total = 0;
    uint64_t locked = 0;
    uint64_t unconfirmed = 0;
    uint64_t spendable = 0;
    NSArray* outputArr = [self.token_outputs_dic objectForKey:tokenType];
    for (VcashTokenOutput* output in outputArr){
        switch (output.status) {
            case Unconfirmed:{
                total += output.value;
                unconfirmed += output.value;
                break;
            }
            case Unspent:{
                total += output.value;
                if ([output isSpendable]){
                    spendable += output.value;
                }
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

-(id)identifyUtxoOutput:(NodeOutput*)nodeOutput{
    NSData* commit = BTCDataFromHex(nodeOutput.commit);
    NSData* proof = BTCDataFromHex(nodeOutput.proof);
    VcashProofInfo* info = [self.mKeyChain rewindProof:commit withProof:proof];
    if (info.isSuc && info.message.length == 20){
        VcashKeychainPath* keyPath;
        uint8_t switchType = SwitchCommitmentTypeRegular;
        if (info.version == 0){
            keyPath = [[VcashKeychainPath alloc] initWithDepth:3 andPathData:[info.message subdataWithRange:NSMakeRange(4, 16)]];
        }
        else if(info.version == 1){
            switchType = *(uint8_t*)&info.message.bytes[2];
            uint8_t* depth = (uint8_t*)&info.message.bytes[3];
            keyPath = [[VcashKeychainPath alloc] initWithDepth:*depth andPathData:[info.message subdataWithRange:NSMakeRange(4, 16)]];
        }
        NSData* retCommit = [self.mKeyChain createCommitment:info.value andKeypath:keyPath andSwitchType:switchType];
        if (![nodeOutput.commit isEqualToString:BTCHexFromData(retCommit)]){
            DDLogError(@"rewindProof suc, but message data is invalid. commit = %@", nodeOutput.commit);
            return nil;
        }
        
        if (nodeOutput.token_type.length > 0){
            VcashTokenOutput* output = [VcashTokenOutput new];
            output.token_type = nodeOutput.token_type;
            output.commitment = nodeOutput.commit;
            output.keyPath = keyPath.pathStr;
            output.mmr_index = nodeOutput.mmr_index;
            output.value = info.value;
            output.height = nodeOutput.block_height;
            output.is_token_issue = [nodeOutput.output_type isEqualToString:@"TokenIsuue"];
            output.lock_height = nodeOutput.block_height;
            output.status = Unspent;
            
            return output;
        }
        else {
            VcashOutput* output = [VcashOutput new];
            output.commitment = nodeOutput.commit;
            output.keyPath = keyPath.pathStr;
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
            
            return output;
        }
    }

    return nil;
}

-(void)sendTransaction:(uint64_t)amount andFee:(uint64_t)fee withComplete:(RequestCompleteBlock)block{
    uint64_t total = 0;
    NSMutableArray* spendable = [NSMutableArray new];
    for (VcashOutput* item in self.outputs){
        if ([item isSpendable]){
            [spendable addObject:item];
            total += item.value;
        }
    }
    
    //1 Compute Fee and output
    // 1.1First attempt to spend without change
    uint64_t actualFee = fee;
    if (fee == 0){
        actualFee = [self calcuteFee:spendable.count withOutputCount:1 withKernelCount:1 withTokenInputCount:0 withTokenOutputCount:0 withTokenKernelCount:0];
    }
    
    uint64_t amount_with_fee = amount + actualFee;
    if (total < amount_with_fee){
        
        NSString* errMsg = [NSString stringWithFormat:[LanguageService contentForKey:@"insufficientFundsWaring"], @([WalletWrapper nanoToVcash:amount_with_fee]),@([WalletWrapper nanoToVcash:total])];
        block?block(NO, errMsg):nil;
        return;
    }
    
    // 1.2Second attempt to spend with change
    if (total != amount_with_fee) {
        actualFee = [self calcuteFee:spendable.count withOutputCount:2 withKernelCount:1 withTokenInputCount:0 withTokenOutputCount:0 withTokenKernelCount:0];
    }
    amount_with_fee = amount + actualFee;
    if (total < amount_with_fee){
        NSString* errMsg = [NSString stringWithFormat:[LanguageService contentForKey:@"insufficientFundsWaring"], @([WalletWrapper nanoToVcash:amount_with_fee]),@([WalletWrapper nanoToVcash:total])];
        block?block(NO, errMsg):nil;
        return;
    }
    uint64_t change = total - amount_with_fee;
    
    //2 fill txLog and slate
    VcashSlate* slate = [VcashSlate new];
    slate.num_participants = 2;
    slate.amount = amount;
    slate.fee = actualFee;
    slate.kernel_features = 0;
    slate.state = Standard1;
    
    VcashTxLog* txLog = [VcashTxLog new];
    txLog.tx_id = [[VcashWallet shareInstance] getNextLogId];
    txLog.tx_slate_id = slate.uuid;
    txLog.tx_type = TxSent;
    txLog.create_time = [[NSDate date] timeIntervalSince1970];
    txLog.fee = slate.fee;
    txLog.amount_credited = change;
    txLog.amount_debited = total;
    txLog.confirm_state = DefaultState;
    slate.txLog = txLog;
    
    VcashCommitId* changeOutputid = [VcashCommitId new];
    VcashSecretKey* blind = [slate addTxElement:spendable change:change changeCommitId:changeOutputid isForToken:NO];
    if (!blind){
        DDLogError(@"--------sender addTxElement failed");
        block?block(NO, nil):nil;
        return;
    }
    
    //3 construct sender Context
    VcashContext* context = [[VcashContext alloc] init];
    context.sec_key = blind;
    context.slate_id = slate.uuid;
    context.amount = amount;
    context.fee = slate.fee;
    
    //add input for Context
    for (VcashOutput* item in spendable){
        VcashCommitId* outputid = [VcashCommitId new];
        outputid.keyPath = item.keyPath;
        outputid.mmr_index = @(item.mmr_index);
        outputid.value = item.value;
        [context.input_ids addObject:outputid];
    }
    if (change > 0) {
        [context.output_ids addObject:changeOutputid];
    }
    
    slate.context = context;
    
    //4 sender fill round 1
    if (![slate fillRound1:context]){
        DDLogError(@"--------sender fillRound1 failed");
        block?block(NO, nil):nil;
        return;
    }
    
    slate.tx = nil;

    block?block(YES, slate):nil;
}

-(void)sendTokenTransaction:(NSString*)token_type andAmount:(uint64_t)amount withComplete:(RequestCompleteBlock)block{
    uint64_t total = 0;
    NSMutableArray* spendable = [NSMutableArray new];
    NSArray* tokens = self.token_outputs_dic[token_type];
    for (VcashTokenOutput* item in tokens){
        if ([item isSpendable]){
            [spendable addObject:item];
            total += item.value;
        }
    }
    
    if (total < amount) {
        NSString* errMsg = [NSString stringWithFormat:[LanguageService contentForKey:@"insufficientFundsWaring"], @([WalletWrapper nanoToVcash:amount]),@([WalletWrapper nanoToVcash:total])];
        block?block(NO, errMsg):nil;
        return;
    }
    uint64_t change = total - amount;
    
    uint64_t vcash_total = 0;
    NSMutableArray* vcash_spendable = [NSMutableArray new];
    for (VcashOutput* item in self.outputs){
        if ([item isSpendable]){
            [vcash_spendable addObject:item];
            vcash_total += item.value;
        }
    }
    
    //assume spend all vcash input as fee
    NSUInteger token_output_count = change > 0? 2: 1;
    uint64_t fee1 = [self calcuteFee:vcash_spendable.count withOutputCount:1 withKernelCount:1 withTokenInputCount:spendable.count withTokenOutputCount:token_output_count withTokenKernelCount:1];
    if (vcash_total < fee1) {
        NSString* errMsg = [NSString stringWithFormat:[LanguageService contentForKey:@"insufficientFundsWaring"], @([WalletWrapper nanoToVcash:fee1]),@([WalletWrapper nanoToVcash:vcash_total])];
        block?block(NO, errMsg):nil;
        return;
    }
    
    //assume 1 vcash input and 1 vcash output, spend all token input with 1 token chang output
    uint64_t fee2 = [self calcuteFee:1 withOutputCount:1 withKernelCount:1 withTokenInputCount:spendable.count withTokenOutputCount:token_output_count withTokenKernelCount:1];
    [vcash_spendable sortUsingComparator:^NSComparisonResult(VcashOutput*  _Nonnull obj1, VcashOutput*  _Nonnull obj2) {
        if (obj1.value >= obj2.value) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];
    
    VcashOutput* input = nil;
    for (VcashOutput* item in vcash_spendable){
        if (item.value >= fee2){
            input = item;
            break;
        }
    }
    
    uint64_t actualFee = 0;
    uint64_t vcash_input_total = 0;
    NSArray* vcash_actual_spend = nil;
    if (input) {
        vcash_input_total = input.value;
        actualFee = fee2;
        vcash_actual_spend = [NSArray arrayWithObject:input];
    }else {
        vcash_input_total = vcash_total;
        actualFee = fee1;
        vcash_actual_spend = vcash_spendable;
    }
    uint64_t vcash_change = vcash_input_total - actualFee;
    

    //fill tokentxLog and slate
    VcashSlate* slate = [VcashSlate new];
    slate.num_participants = 2;
    slate.token_type = token_type;
    slate.amount = amount;
    slate.fee = actualFee;
    slate.kernel_features = 0;
    slate.token_kernel_features = 0;
    slate.state = Standard1;
    
    VcashTokenTxLog* txLog = [VcashTokenTxLog new];
    txLog.tx_id = [[VcashWallet shareInstance] getNextLogId];
    txLog.token_type = token_type;
    txLog.tx_slate_id = slate.uuid;
    txLog.tx_type = TxSent;
    txLog.create_time = [[NSDate date] timeIntervalSince1970];
    txLog.fee = slate.fee;
    txLog.amount_credited = vcash_change;
    txLog.amount_debited = vcash_input_total;
    txLog.token_amount_credited = change;
    txLog.token_amount_debited = total;
    txLog.confirm_state = DefaultState;
    slate.tokenTxLog = txLog;
    
    VcashCommitId* changeOutputid = [VcashCommitId new];
    VcashSecretKey* blind = [slate addTxElement:vcash_actual_spend change:vcash_change changeCommitId:changeOutputid isForToken:YES];
    if (!blind){
        DDLogError(@"--------sender addTxElement failed");
        block?block(NO, nil):nil;
        return;
    }
    
    VcashCommitId* tokenChangeOutputid = [VcashCommitId new];
    VcashSecretKey* token_blind = [slate addTokenTxElement:spendable change:change changeCommitId:tokenChangeOutputid];
    if (!blind){
        DDLogError(@"--------sender addTokenTxElement failed");
        block?block(NO, nil):nil;
        return;
    }
    
    //3 construct sender Context
    VcashContext* context = [[VcashContext alloc] init];
    context.sec_key = blind;
    context.token_sec_key = token_blind;
    context.slate_id = slate.uuid;
    context.amount = amount;
    context.fee = slate.fee;
    
    //add input for Context
    for (VcashOutput* item in vcash_actual_spend){
        VcashCommitId* outputid = [VcashCommitId new];
        outputid.keyPath = item.keyPath;
        outputid.mmr_index = @(item.mmr_index);
        outputid.value = item.value;
        [context.input_ids addObject:outputid];
    }
    if (vcash_change > 0) {
        [context.output_ids addObject:changeOutputid];
    }
    
    //add token input for Context
    for (VcashTokenOutput* item in spendable){
        VcashCommitId* outputid = [VcashCommitId new];
        outputid.keyPath = item.keyPath;
        outputid.mmr_index = @(item.mmr_index);
        outputid.value = item.value;
        [context.token_input_ids addObject:outputid];
    }
    if (change > 0) {
        [context.token_output_ids addObject:tokenChangeOutputid];
    }
    
    slate.context = context;
    
    //4 sender fill round 1
    if (![slate fillRound1:context]){
        DDLogError(@"--------sender fillRound1 failed");
        block?block(NO, nil):nil;
        return;
    }
    
    slate.tx = nil;
    
    block?block(YES, slate):nil;
}

-(BOOL)receiveTransaction:(VcashSlate*)slate{
    //5, fill slate with receiver output
    if (slate.token_type) {
        VcashTokenTxLog* txLog = [VcashTokenTxLog new];
        txLog.tx_id = [[VcashWallet shareInstance] getNextLogId];
        txLog.tx_slate_id = slate.uuid;
        txLog.tx_type = TxReceived;
        txLog.create_time = [[NSDate date] timeIntervalSince1970];
        txLog.token_type = slate.token_type;
        txLog.token_amount_credited = slate.amount;
        txLog.amount_debited = 0;
        txLog.confirm_state = DefaultState;
        slate.tokenTxLog = txLog;
    } else {
        VcashTxLog* txLog = [VcashTxLog new];
        txLog.tx_id = [[VcashWallet shareInstance] getNextLogId];
        txLog.tx_slate_id = slate.uuid;
        txLog.tx_type = TxReceived;
        txLog.create_time = [[NSDate date] timeIntervalSince1970];
        txLog.fee = slate.fee;
        txLog.amount_credited = slate.amount;
        txLog.amount_debited = 0;
        txLog.confirm_state = DefaultState;
        slate.txLog = txLog;
    }
    
    VcashCommitId* commitId = [VcashCommitId new];
    VcashSecretKey* blind = [slate addReceiverTxOutputWithChangeCommitId:commitId];
    if (!blind){
        DDLogError(@"--------receiver addReceiverTxOutput failed");
        return NO;
    }
    
    //6, construct receiver Context
    VcashContext* context = [[VcashContext alloc] init];
    if (slate.token_type) {
        context.token_sec_key = blind;
    } else {
        context.sec_key = blind;
    }
    context.slate_id = slate.uuid;
    context.amount = slate.amount;
    context.fee = slate.fee;
    if (slate.token_type) {
        [context.token_output_ids addObject:commitId];
    } else {
        [context.output_ids addObject:commitId];
    }
    
    slate.context = context;
    
    //7, receiver fill round 1
    if (![slate fillRound1:context]){
        DDLogError(@"--------receiver fillRound1 failed");
        return NO;
    }
    
    //8, receiver fill round 2
    if (![slate fillRound2:context]){
        DDLogError(@"--------receiver fillRound2 failed");
        return NO;
    }
    
    return YES;
}

-(BOOL)finalizeTransaction:(VcashSlate*)slate{
    VcashContext* context = slate.context;
    
    //compute offset
    [slate subInputFromOffset:context];
    
    //construct tx
    [slate repopulateTx:context];
    
    
    //9, sender fill round 2
    if (![slate fillRound2:context])
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

    return YES;
}

-(VcashKeychainPath*)nextChild{
    if (_curKeyPath){
        _curKeyPath = [_curKeyPath nextPath];
        [self saveBaseInfo];
    }
    else{
        _curKeyPath = [[VcashKeychainPath alloc] initWithDepth:3 d0:0 d1:0 d2:0 d3:0];
    }

    return _curKeyPath;
}

-(uint32_t)getNextLogId{
    self->_curTxLogId += 1;
    [self saveBaseInfo];
    return _curTxLogId;
}

-(void)tokenOutputToDic{
    NSMutableDictionary* dic = [NSMutableDictionary new];
    for (VcashTokenOutput* item in self->_tokenOutputs){
        NSMutableArray* arr = [dic objectForKey:item.token_type];
        if (arr == nil){
            arr = [NSMutableArray new];
            [dic setObject:arr forKey:item.token_type];
        }
        [arr addObject:item];
    }
    self->_token_outputs_dic = dic;
}

#pragma private
-(uint64_t)calcuteFee:(NSInteger)inputCount withOutputCount:(NSInteger)outputCount withKernelCount:(NSInteger)kernelCount withTokenInputCount:(NSInteger)tokenInputCount withTokenOutputCount:(NSInteger)tokenOutputCount withTokenKernelCount:(NSInteger)tokenKernelCount{
    NSInteger tx_weight = outputCount * 4 + kernelCount*1 - inputCount;
    if (tx_weight < 0) {
        tx_weight = 0;
    }
    
    NSInteger token_tx_weight = tokenOutputCount * 4 + tokenKernelCount*1 - tokenInputCount;
    if (token_tx_weight < 0) {
        token_tx_weight = 0;
    }
    
    NSInteger total_weight = tx_weight + token_tx_weight;
    total_weight = (total_weight>1?total_weight:1);
    
    return DEFAULT_BASE_FEE*total_weight;
}

-(void)saveBaseInfo{
    VcashWalletInfo* info = [VcashWalletInfo new];
    info.curKeyPath = _curKeyPath.pathStr;
    info.curHeight = self.curChainHeight;
    info.curTxLogId = _curTxLogId;
    
    [[VcashDataManager shareInstance] saveWalletInfo:info];
}

@end


@implementation WalletBalanceInfo


@end
