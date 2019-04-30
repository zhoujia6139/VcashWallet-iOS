//
//  VcashWalletInfo+WCTTableCoding.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/25.
//  Copyright © 2019年 blockin. All rights reserved.
//

#ifndef VcashWalletInfo_WCTTableCoding_h
#define VcashWalletInfo_WCTTableCoding_h

@interface VcashWalletInfo(WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(curKeyPath)
WCDB_PROPERTY(curHeight)
WCDB_PROPERTY(curTxLogId)

@end

#endif /* VcashWalletInfo_WCTTableCoding_h */
