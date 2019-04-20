//
//  VcashSecp256k1.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/19.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashSecp256k1.h"
#include "VcashConstant.h"

@implementation VcashSecp256k1
{
    secp256k1_context* _context;
    unsigned int _flag;
}

- (id) initWithFlag:(unsigned int)flags {
    if (self = [super init]) {
        _context = secp256k1_context_create(flags);
        _flag = flags;
    }
    return self;
}

-(NSData*)blindSwitch:(uint64_t)value withKey:(NSData*)key {
    return nil;
}

-(BOOL)verifyEcSecretKey:(NSData*)data {
    if (data.length == SECRET_KEY_SIZE) {
        if (secp256k1_ec_seckey_verify(_context, data.bytes) == 1) {
            return YES;
        }
    }
    return NO;
}


@end
