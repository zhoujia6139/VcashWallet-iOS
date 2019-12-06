//
//  VcashContext+WCTTableCoding.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/29.
//  Copyright © 2019年 blockin. All rights reserved.
//

#ifndef VcashContext_WCTTableCoding_h
#define VcashContext_WCTTableCoding_h
#import "VcashContext.h"

@interface VcashContext(WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(sec_key)
WCDB_PROPERTY(token_sec_key)
WCDB_PROPERTY(sec_nounce)
WCDB_PROPERTY(slate_id)

@end

#endif /* VcashContext_WCTTableCoding_h */
