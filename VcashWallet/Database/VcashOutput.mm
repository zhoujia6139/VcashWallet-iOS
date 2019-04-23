//
//  VcashOutput.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashOutput.h"
#import <WCDB/WCDB.h>

@implementation VcashOutput

WCDB_IMPLEMENTATION(VcashOutput)
WCDB_SYNTHESIZE(VcashOutput, commit)
WCDB_SYNTHESIZE(VcashOutput, keyPath)
WCDB_SYNTHESIZE(VcashOutput, mmr_index)
WCDB_SYNTHESIZE(VcashOutput, value)
WCDB_SYNTHESIZE(VcashOutput, height)
WCDB_SYNTHESIZE(VcashOutput, lock_height)
WCDB_SYNTHESIZE(VcashOutput, is_coinbase)
WCDB_SYNTHESIZE(VcashOutput, status)

WCDB_PRIMARY(VcashOutput, commit)

@end
