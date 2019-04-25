//
//  VcashSlate.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VcashContext, ParticipantData, VcashTransaction;

@interface VcashSlate : NSObject

@property(strong, nonatomic)NSString* uuid;

@property(assign, nonatomic)uint16_t num_participants;

@property(assign, nonatomic)uint64_t amount;

@property(assign, nonatomic)uint64_t fee;

@property(assign, nonatomic)uint64_t height;

@property(assign, nonatomic)uint64_t lock_height;

@property(assign, nonatomic)uint64_t version;

@property(strong, nonatomic)VcashTransaction* tx;

@property(strong, nonatomic)NSMutableArray<ParticipantData*>* participant_data;

//for sender
-(VcashSecretKey*)addTxElement:(NSArray*)outputs change:(uint64_t)change;

//for receiver
-(VcashSecretKey*)addReceiverTxOutput;

-(BOOL)fillRound1:(VcashContext*)context participantId:(NSUInteger)participant_id andMessage:(NSString*)message;

-(BOOL)fillRound2:(VcashContext*)context participantId:(NSUInteger)participant_id;

@end

@interface ParticipantData : NSObject

@property(assign, nonatomic)uint16_t pId;

@property(strong, nonatomic)NSData* public_blind_excess;

@property(strong, nonatomic)NSData* public_nonce;

@property(strong, nonatomic)NSData* part_sig;

@property(strong, nonatomic)NSString* message;

@property(strong, nonatomic)NSData* message_sig;

@end

NS_ASSUME_NONNULL_END
