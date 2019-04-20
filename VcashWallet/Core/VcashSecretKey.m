//
//  VcashSecretKey.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/20.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashSecretKey.h"
#include "VcashConstant.h"
#import "VcashSecp256k1.h"

@implementation VcashSecretKey
{
    NSData* _data;
}

- (id) initWithDate:(NSData*)data{
    if (self = [super init]) {
        if (data.length != SECRET_KEY_SIZE)
        {
            return nil;
        }
        _data = data;
    }
    return self;
}

@end
