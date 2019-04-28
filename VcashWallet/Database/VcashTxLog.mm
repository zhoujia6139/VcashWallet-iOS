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
WCDB_SYNTHESIZE(VcashTxLog, is_confirmed)
WCDB_SYNTHESIZE(VcashTxLog, amount_credited)
WCDB_SYNTHESIZE(VcashTxLog, amount_debited)
WCDB_SYNTHESIZE(VcashTxLog, fee)

WCDB_PRIMARY_ASC_AUTO_INCREMENT(VcashTxLog, tx_id)

@end
