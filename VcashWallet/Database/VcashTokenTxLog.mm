//
//  VcashTxLog.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashTokenTxLog.h"
#import <WCDB/WCDB.h>
#import "VcashTokenTxLog+WCTTableCoding.h"

@implementation VcashTokenTxLog

WCDB_IMPLEMENTATION(VcashTokenTxLog)
WCDB_SYNTHESIZE(VcashTokenTxLog, tx_id)
WCDB_SYNTHESIZE(VcashTokenTxLog, tx_slate_id)
WCDB_SYNTHESIZE(VcashTokenTxLog, parter_id)
WCDB_SYNTHESIZE(VcashTokenTxLog, tx_type)
WCDB_SYNTHESIZE(VcashTokenTxLog, create_time)
WCDB_SYNTHESIZE(VcashTokenTxLog, confirm_time)
WCDB_SYNTHESIZE(VcashTokenTxLog, confirm_height)
WCDB_SYNTHESIZE(VcashTokenTxLog, confirm_state)
WCDB_SYNTHESIZE(VcashTokenTxLog, status)
WCDB_SYNTHESIZE(VcashTokenTxLog, token_type)
WCDB_SYNTHESIZE(VcashTokenTxLog, amount_credited)
WCDB_SYNTHESIZE(VcashTokenTxLog, amount_debited)
WCDB_SYNTHESIZE(VcashTokenTxLog, token_amount_credited)
WCDB_SYNTHESIZE(VcashTokenTxLog, token_amount_debited)
WCDB_SYNTHESIZE(VcashTokenTxLog, fee)
WCDB_SYNTHESIZE(VcashTokenTxLog, inputs)
WCDB_SYNTHESIZE(VcashTokenTxLog, outputs)
WCDB_SYNTHESIZE(VcashTokenTxLog, token_inputs)
WCDB_SYNTHESIZE(VcashTokenTxLog, token_outputs)
WCDB_SYNTHESIZE(VcashTokenTxLog, signed_slate_msg)

WCDB_PRIMARY(VcashTokenTxLog, tx_id)

-(void)appendInput:(NSString*)commitment{
    NSMutableArray* arr = (NSMutableArray*)self.inputs;
    if (!arr){
        arr = [NSMutableArray new];
        self.inputs = arr;
    }
    [arr addObject:commitment];
}

-(void)appendOutput:(NSString*)commitment{
    NSMutableArray* arr = (NSMutableArray*)self.outputs;
    if (!arr){
        arr = [NSMutableArray new];
        self.outputs = arr;
    }
    [arr addObject:commitment];
}

-(void)appendTokenInput:(NSString*)commitment{
    NSMutableArray* arr = (NSMutableArray*)self.token_inputs;
    if (!arr){
        arr = [NSMutableArray new];
        self.token_inputs = arr;
    }
    [arr addObject:commitment];
}

-(void)appendTokenOutput:(NSString*)commitment{
    NSMutableArray* arr = (NSMutableArray*)self.token_outputs;
    if (!arr){
        arr = [NSMutableArray new];
        self.token_outputs = arr;
    }
    [arr addObject:commitment];
}

-(BOOL)isCanBeCanneled{
    if (self.tx_type == TxSent && self.confirm_state == DefaultState){
        return YES;
    }else if (self.tx_type == TxReceived && !self.parter_id && self.signed_slate_msg && self.confirm_state != NetConfirmed){
        return YES;
    }
    
    return NO;
}

-(void)cancelTxlog{
    NSArray* walletOutputs = [VcashWallet shareInstance].outputs;
    if (self.tx_type == TxSent){
        for (NSString* commitment in self.inputs){
            for (VcashOutput* item in walletOutputs){
                if ([commitment isEqualToString:item.commitment]){
                    item.status = Unspent;
                }
            }
        }
    }
    
    for (NSString* commitment in self.outputs){
        for (VcashOutput* item in walletOutputs){
            if ([commitment isEqualToString:item.commitment]){
                item.status = Spent;
            }
        }
    }
    [[VcashWallet shareInstance] syncOutputInfo];
    
    self.tx_type = (self.tx_type == TokenTxSent?TokenTxSentCancelled:TokenTxReceivedCancelled);
    self.status = TxCanceled;
    
    return;
}

@end
