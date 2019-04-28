//
//  VcashTxLog+WCTTableCoding.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#ifndef VcashTxLog_WCTTableCoding_h
#define VcashTxLog_WCTTableCoding_h


@interface VcashTxLog(WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(tx_id)
WCDB_PROPERTY(tx_slate_id)
WCDB_PROPERTY(tx_type)
WCDB_PROPERTY(create_time)
WCDB_PROPERTY(confirm_time)
WCDB_PROPERTY(is_confirmed)
WCDB_PROPERTY(amount_credited)
WCDB_PROPERTY(amount_debited)
WCDB_PROPERTY(fee)

@end

#endif /* VcashTxLog_WCTTableCoding_h */
