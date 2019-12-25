//
//  VcashTxLog.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerType.h"
#import "BaseVcashTxLog.h"

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


@interface VcashTxLog : BaseVcashTxLog

@property(assign, nonatomic)TxLogEntryType tx_type;

@property(assign, nonatomic)uint64_t amount_credited;

@property(assign, nonatomic)uint64_t amount_debited;

@property(assign, nonatomic)uint64_t fee;

@property(strong, nonatomic)NSArray<NSString*>* inputs;

@property(strong, nonatomic)NSArray<NSString*>* outputs;

@property(strong, nonatomic)NSString* signed_slate_msg;

-(void)appendInput:(NSString*)commitment;

-(void)appendOutput:(NSString*)commitment;

@end

NS_ASSUME_NONNULL_END
