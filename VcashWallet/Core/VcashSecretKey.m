//
//  VcashSecretKey.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/20.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashSecretKey.h"
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

- (id)initWithCoder:(NSCoder *)coder{
    if (self = [super init]){
        self->_data = [coder decodeObjectForKey:@"data"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder{
    [coder encodeObject:self.data forKey:@"data"];
}

+(instancetype)nounceKey{
    NSData* data = BTCRandomDataWithLength(SECRET_KEY_SIZE);
    VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
    while (![secp verifyEcSecretKey:data]){
        data = BTCRandomDataWithLength(SECRET_KEY_SIZE);
    }
    VcashSecretKey* key = [VcashSecretKey new];
    key->_data = data;
    return key;
}

+(instancetype)zeroKey{
    uint8_t buf[SECRET_KEY_SIZE] = {0};
    NSData* data = [[NSData alloc] initWithBytes:buf length:SECRET_KEY_SIZE];
    VcashSecretKey* key = [VcashSecretKey new];
    key->_data = data;
    return key;
}

@end
