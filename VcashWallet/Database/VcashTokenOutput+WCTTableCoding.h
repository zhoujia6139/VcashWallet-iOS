//
//  VcashOutput+WCTTableCoding.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#ifndef VcashTokenOutput_WCTTableCoding_h
#define VcashTokenOutput_WCTTableCoding_h

#import "VcashTokenOutput.h"
#import <WCDB/WCDB.h>

@interface VcashTokenOutput(WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(commitment)
WCDB_PROPERTY(token_type)
WCDB_PROPERTY(keyPath)
WCDB_PROPERTY(mmr_index)
WCDB_PROPERTY(value)
WCDB_PROPERTY(height)
WCDB_PROPERTY(lock_height)
WCDB_PROPERTY(is_token_issue)
WCDB_PROPERTY(status)
WCDB_PROPERTY(tx_log_id)

@end

#endif /* VcashTokenOutput_WCTTableCoding_h */
