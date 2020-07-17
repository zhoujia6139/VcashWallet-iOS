//
//  VcashSlate.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VcashContext, VersionCompatInfo, PaymentInfo, ParticipantData, VcashTransaction, VcashTxLog, VcashTokenTxLog, VcashSignature, KernelFeaturesArgs, VcashCommitId, Output, TokenOutput;

typedef enum {
    /// Unknown, coming from earlier slate versions
    Unknown = 0,
    /// Standard flow, freshly init
    Standard1 = 1,
    /// Standard flow, return journey
    Standard2 = 2,
    /// Standard flow, ready for transaction posting
    Standard3 = 3,
    /// Invoice flow, freshly init
    Invoice1 = 4,
    ///Invoice flow, return journey
    Invoice2 = 5,
    /// Invoice flow, ready for tranasction posting
    Invoice3 = 6,
}SlateState;

@interface VcashSlate : NSObject

@property(strong, nonatomic)VersionCompatInfo* version_info;

@property(assign, nonatomic)uint16_t num_participants;

@property(strong, nonatomic)NSString* uuid;

@property(assign, nonatomic)SlateState state;

@property(assign, nonatomic)uint64_t amount;

@property(strong, nonatomic)NSString* token_type;

@property(assign, nonatomic)uint64_t fee;

@property(assign, nonatomic)uint64_t ttl_cutoff_height;

@property(assign, nonatomic)uint8_t kernel_features;

@property(assign, nonatomic)uint8_t token_kernel_features;

@property(strong, nonatomic)NSData* offset;

@property(strong, nonatomic)NSMutableArray<ParticipantData*>* participant_data;

@property(strong, nonatomic)PaymentInfo* payment_proof;

@property(strong, nonatomic)KernelFeaturesArgs* kernel_features_args;

@property(strong, nonatomic)KernelFeaturesArgs* token_kernel_features_args;

@property(strong, nonatomic)NSString* partnerAddress;


//json unselialised
@property(strong, nonatomic, nullable)VcashTransaction* tx;

@property(strong, nonatomic)VcashTxLog* txLog;

@property(strong, nonatomic)VcashTokenTxLog* tokenTxLog;

@property(strong, nonatomic)dispatch_block_t lockOutputsFn;

@property(strong, nonatomic)dispatch_block_t lockTokenOutputsFn;

@property(strong, nonatomic)dispatch_block_t createNewOutputsFn;

@property(strong, nonatomic)dispatch_block_t createNewTokenOutputsFn;

@property(strong, nonatomic)VcashContext* context;

+(VcashSlate*)parseSlateFromData:(NSData*)binData;

-(NSData*)selializeAsData;

//for sender
-(VcashSecretKey*)addTxElement:(NSArray*)outputs change:(uint64_t)change changeCommitId:(VcashCommitId*)changeCommitId isForToken:(BOOL)isForToken;

-(VcashSecretKey*)addTokenTxElement:(NSArray*)token_outputs change:(uint64_t)change changeCommitId:(VcashCommitId*)changeCommitId;

//for receiver
-(VcashSecretKey*)addReceiverTxOutputWithChangeCommitId:(VcashCommitId*)changeCommitId;

-(BOOL)fillRound1:(VcashContext*)context;

-(BOOL)fillRound2:(VcashContext*)context;

-(void)removeOtherSigdata;

-(void)subInputFromOffset:(VcashContext*)context;

-(void)repopulateTx:(VcashContext*)context;

-(VcashSignature*)finalizeSignature;

-(BOOL)finalizeTx:(VcashSignature*)finalSig;

-(NSData*)calculateExcess;

-(NSData*)participantPublicBlindSum;

-(BOOL)isValidForReceive;

-(BOOL)isValidForFinalize;

@end

@interface VersionCompatInfo : NSObject

@property(assign, nonatomic)uint16_t version;

@property(assign, nonatomic)uint16_t block_header_version;

+(instancetype)createVersionInfo;

@end

@interface ParticipantData : NSObject

@property(strong, nonatomic)NSData* public_blind_excess;

@property(strong, nonatomic)NSData* public_nonce;

@property(strong, nonatomic)VcashSignature* part_sig;

@end

@interface PaymentInfo : NSObject

@property(strong, nonatomic)NSString* sender_address;

@property(strong, nonatomic)NSString* receiver_address;

@property(strong, nonatomic)NSString* receiver_signature;

@end

@interface KernelFeaturesArgs : NSObject

@property(assign, nonatomic)uint64_t lock_height;

@end

NS_ASSUME_NONNULL_END
