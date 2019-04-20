//
//  VcashSecp256k1.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/19.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashSecp256k1.h"

@implementation VcashSecp256k1
{
    secp256k1_context* context;
    unsigned int flag;
}

- (id) initWithFlag:(unsigned int)flags {
    if (self = [super init]) {
        context = secp256k1_context_create(flags);
        flag = flags;
    }
    return self;
}

-(NSData*)blindSwitch:(uint64_t)value withKey:(NSData*)key {
    return nil;
}


@end
