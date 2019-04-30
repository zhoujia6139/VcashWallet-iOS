//
//  VcashOutput+WCTTableCoding.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#ifndef VcashOutput_WCTTableCoding_h
#define VcashOutput_WCTTableCoding_h

#import "VcashOutput.h"
#import <WCDB/WCDB.h>

@interface VcashOutput(WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(commitment)
WCDB_PROPERTY(keyPath)
WCDB_PROPERTY(mmr_index)
WCDB_PROPERTY(value)
WCDB_PROPERTY(height)
WCDB_PROPERTY(lock_height)
WCDB_PROPERTY(is_coinbase)
WCDB_PROPERTY(status)
WCDB_PROPERTY(tx_log_id)

@end

#endif /* VcashOutput_WCTTableCoding_h */
