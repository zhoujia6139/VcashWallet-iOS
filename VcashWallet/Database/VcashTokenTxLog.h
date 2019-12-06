//
//  VcashTxLog.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerType.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum  {
    /// Sent transaction that was rolled back by user
    TokenIssue,
    /// Outputs created when a transaction is received
    TokenTxReceived,
    /// Inputs locked + change outputs when a transaction is created
    TokenTxSent,
    /// Received token transaction that was rolled back by user
    TokenTxReceivedCancelled,
    /// Sent token transaction that was rolled back by user
    TokenTxSentCancelled,
}TokenTxLogEntryType;

@interface VcashTokenTxLog : NSObject

@property(assign, nonatomic)uint32_t tx_id;

@property(strong, nonatomic)NSString* tx_slate_id;

@property(strong, nonatomic)NSString* parter_id;

@property(assign, nonatomic)TokenTxLogEntryType tx_type;

@property(assign, nonatomic)uint64_t create_time;

@property(assign, nonatomic)uint64_t confirm_time;

@property(assign, nonatomic)uint64_t confirm_height;

@property(assign, nonatomic)TxLogConfirmType confirm_state;

@property(assign, nonatomic)ServerTxStatus status;

@property(strong, nonatomic)NSString* token_type;

@property(assign, nonatomic)uint64_t amount_credited;

@property(assign, nonatomic)uint64_t amount_debited;

@property(assign, nonatomic)uint64_t token_amount_credited;

@property(assign, nonatomic)uint64_t token_amount_debited;

@property(assign, nonatomic)uint64_t fee;

@property(strong, nonatomic)NSArray<NSString*>* inputs;

@property(strong, nonatomic)NSArray<NSString*>* outputs;

@property(strong, nonatomic)NSArray<NSString*>* token_inputs;

@property(strong, nonatomic)NSArray<NSString*>* token_outputs;

@property(strong, nonatomic)NSString* signed_slate_msg;

-(void)appendInput:(NSString*)commitment;

-(void)appendOutput:(NSString*)commitment;

-(void)appendTokenInput:(NSString*)commitment;

-(void)appendTokenOutput:(NSString*)commitment;

-(BOOL)isCanBeCanneled;

-(void)cancelTxlog;

@end

NS_ASSUME_NONNULL_END
