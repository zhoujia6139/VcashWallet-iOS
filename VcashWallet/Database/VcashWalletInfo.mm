//
//  VcashWalletInfo.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/25.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashWalletInfo.h"
#import <WCDB/WCDB.h>

@implementation VcashWalletInfo

WCDB_IMPLEMENTATION(VcashWalletInfo)
WCDB_SYNTHESIZE(VcashWalletInfo, curKeyPath)
WCDB_SYNTHESIZE(VcashWalletInfo, curHeight)

@end
