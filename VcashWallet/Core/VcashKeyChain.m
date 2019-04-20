//
//  VcashKeyChain.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/19.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashKeyChain.h"
#import "CoreBitcoin.h"
#import "VcashSecp256k1.h"
#import "VcashKeychainPath.h"
#include "blake2.h"

@implementation VcashKeyChain
{
    VcashSecp256k1* _secp;
    BTCKeychain* _keyChain;
}

- (id) initWithRootKeychain:(BTCKeychain*)keychain {
    if (self = [super init]) {
        _keyChain = keychain;
        _secp = [[VcashSecp256k1 alloc] initWithFlag:(SECP256K1_CONTEXT_VERIFY|SECP256K1_CONTEXT_SIGN)];
    }
    return self;
}

-(NSData*)deriveKey:(uint64_t)amount andKeypath:(VcashKeychainPath*)keypath{
    BTCKey* key = [_keyChain derivedKeychainWithPath:keypath.pathStr].key;
    NSData* data = [_secp blindSwitch:amount withKey:key.privateKey];
    return data;
}

-(NSData*)createNonce:(NSData*)commitment {
    NSData* rootKey = [self deriveKey:0 andKeypath:nil];
    uint8_t ret[32];
    if( blake2b( ret, rootKey.bytes, commitment.bytes, 32, 32, 32 ) < 0)
    {
        return nil;
    }
    return [NSData dataWithBytes:ret length:32];
}

@end
