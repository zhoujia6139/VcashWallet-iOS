//
//  VcashTxLog.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashTxLog.h"
#import <WCDB/WCDB.h>
#import "VcashTxLog+WCTTableCoding.h"

@implementation VcashTxLog

WCDB_IMPLEMENTATION(VcashTxLog)
WCDB_SYNTHESIZE(VcashTxLog, tx_id)
WCDB_SYNTHESIZE(VcashTxLog, tx_slate_id)
WCDB_SYNTHESIZE(VcashTxLog, tx_type)
WCDB_SYNTHESIZE(VcashTxLog, create_time)
WCDB_SYNTHESIZE(VcashTxLog, confirm_time)
WCDB_SYNTHESIZE(VcashTxLog, confirm_state)
WCDB_SYNTHESIZE(VcashTxLog, amount_credited)
WCDB_SYNTHESIZE(VcashTxLog, amount_debited)
WCDB_SYNTHESIZE(VcashTxLog, fee)
WCDB_SYNTHESIZE(VcashTxLog, inputs)
WCDB_SYNTHESIZE(VcashTxLog, outputs)

WCDB_PRIMARY(VcashTxLog, tx_id)

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

-(BOOL)isCanBeCanneled{
    if ((self.tx_type == TxSent || self.tx_type == TxReceived)
        && self.confirm_state == DefaultState){
        return YES;
    }
    
    return NO;
}

@end
