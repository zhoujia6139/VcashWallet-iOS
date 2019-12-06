//
//  VcashTxLog+WCTTableCoding.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#ifndef VcashTokenTxLog_WCTTableCoding_h
#define VcashTokenTxLog_WCTTableCoding_h


@interface VcashTokenTxLog(WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(tx_id)
WCDB_PROPERTY(tx_slate_id)
WCDB_PROPERTY(tx_type)
WCDB_PROPERTY(create_time)
WCDB_PROPERTY(confirm_time)
WCDB_PROPERTY(confirm_height)
WCDB_PROPERTY(confirm_state)
WCDB_PROPERTY(token_type)
WCDB_PROPERTY(amount_credited)
WCDB_PROPERTY(amount_debited)
WCDB_PROPERTY(token_amount_credited)
WCDB_PROPERTY(token_amount_debited)
WCDB_PROPERTY(fee)
WCDB_PROPERTY(inputs)
WCDB_PROPERTY(outputs)
WCDB_PROPERTY(token_inputs)
WCDB_PROPERTY(token_outputs)
WCDB_PROPERTY(signed_slate_msg)

@end

#endif /* VcashTokenTxLog_WCTTableCoding_h */
