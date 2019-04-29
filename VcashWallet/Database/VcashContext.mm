//
//  VcashContext.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashContext.h"
#import "VcashWallet.h"
#import "VcashSecp256k1.h"
#import <WCDB/WCDB.h>

@implementation VcashContext

-(id)init{
    self = [super init];
    if (self){
        _sec_nounce = [[VcashWallet shareInstance].mKeyChain.secp exportSecnonceSingle];;
    }
    return self;
}

WCDB_IMPLEMENTATION(VcashContext)
WCDB_SYNTHESIZE(VcashContext, sec_key)
WCDB_SYNTHESIZE(VcashContext, sec_nounce)
WCDB_SYNTHESIZE(VcashContext, slate_id)

WCDB_PRIMARY(VcashContext, slate_id)

@end
