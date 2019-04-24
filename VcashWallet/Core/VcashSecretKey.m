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
#import "CoreBitcoin.h"
#import "VcashWallet.h"

@implementation VcashSecretKey
{
    NSData* _data;
}

- (id) initWithData:(NSData*)data{
    if (self = [super init]) {
        if (data.length != SECRET_KEY_SIZE)
        {
            return nil;
        }
        VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
        if (![secp verifyEcSecretKey:data]){
            return nil;
        }
        _data = data;
    }
    return self;
}

+(instancetype)nounceKey{
    NSData* data = BTCRandomDataWithLength(32);
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    while (![secp verifyEcSecretKey:data]){
        data = BTCRandomDataWithLength(32);
    }
    VcashSecretKey* key = [VcashSecretKey new];
    key->_data = data;
    return key;
}

@end
