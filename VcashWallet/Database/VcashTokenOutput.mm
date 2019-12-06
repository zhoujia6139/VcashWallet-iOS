//
//  VcashOutput.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashTokenOutput.h"
#import <WCDB/WCDB.h>

@implementation VcashTokenOutput

WCDB_IMPLEMENTATION(VcashTokenOutput)
WCDB_SYNTHESIZE(VcashTokenOutput, commitment)
WCDB_SYNTHESIZE(VcashTokenOutput, token_type)
WCDB_SYNTHESIZE(VcashTokenOutput, keyPath)
WCDB_SYNTHESIZE(VcashTokenOutput, mmr_index)
WCDB_SYNTHESIZE(VcashTokenOutput, value)
WCDB_SYNTHESIZE(VcashTokenOutput, height)
WCDB_SYNTHESIZE(VcashTokenOutput, lock_height)
WCDB_SYNTHESIZE(VcashTokenOutput, is_token_issue)
WCDB_SYNTHESIZE(VcashTokenOutput, status)
WCDB_SYNTHESIZE(VcashTokenOutput, tx_log_id)

WCDB_PRIMARY(VcashTokenOutput, commitment)

-(BOOL)isSpendable{
    if (self.status == Unspent &&
        self.lock_height <= [VcashWallet shareInstance].curChainHeight){
        return YES;
    }
    return NO;
}

@end
