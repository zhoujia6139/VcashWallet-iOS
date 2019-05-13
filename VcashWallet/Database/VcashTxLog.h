//
//  VcashTxLog.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum  {
    /// A coinbase transaction becomes confirmed
    ConfirmedCoinbase,
    /// Outputs created when a transaction is received
    TxReceived,
    /// Inputs locked + change outputs when a transaction is created
    TxSent,
    /// Received transaction that was rolled back by user
    TxReceivedCancelled,
    /// Sent transaction that was rolled back by user
    TxSentCancelled,
}TxLogEntryType;

typedef enum {
    /// local tx state
    DefaultState = 0,
    /// tx has benn post, but not confirm by node
    LoalConfirmed,
    /// confirm by node
    NetConfirmed,
}TxLogConfirmType;

@interface VcashTxLog : NSObject

@property(assign, nonatomic)uint32_t tx_id;

@property(strong, nonatomic)NSString* tx_slate_id;

@property(assign, nonatomic)TxLogEntryType tx_type;

@property(assign, nonatomic)uint64_t create_time;

@property(assign, nonatomic)uint64_t confirm_time;

@property(assign, nonatomic)TxLogConfirmType confirm_state;

@property(assign, nonatomic)uint64_t amount_credited;

@property(assign, nonatomic)uint64_t amount_debited;

@property(assign, nonatomic)uint64_t fee;

@property(strong, nonatomic)NSArray<NSString*>* inputs;

@property(strong, nonatomic)NSArray<NSString*>* outputs;

-(void)appendInput:(NSString*)commitment;

-(void)appendOutput:(NSString*)commitment;

-(BOOL)isCanBeCanneled;

-(BOOL)cannelTx;

@end

NS_ASSUME_NONNULL_END
