//
//  VcashKeyChain.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/19.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashKeyChain.h"
#import "VcashSecp256k1.h"
#include "blake2.h"
#include "VcashConstant.h"

@implementation VcashKeyChain
{
    BTCKeychain* _keyChain;
    BTCMnemonic* _mnemonic;
}

- (id) initWithMnemonic:(BTCMnemonic*)mnemonic {
    if (self = [super init]) {
        _keyChain = mnemonic.keychain;
        _mnemonic = mnemonic;
        _secp = [[VcashSecp256k1 alloc] initWithFlag:ContextCommit];
    }
    return self;
}

-(VcashSecretKey*)deriveKey:(uint64_t)amount andKeypath:(VcashKeychainPath*)keypath{
    BTCKeychain* keychain = [_keyChain derivedKeychainWithPath:keypath.pathStr];
    BTCKey* key = keychain.key;
    NSData* data = [_secp blindSwitch:amount withKey:[[VcashSecretKey alloc] initWithData:key.privateKey]];
    return [[VcashSecretKey alloc] initWithData:data];
}

-(NSData*)createCommitment:(uint64_t)amount andKeypath:(VcashKeychainPath*)keypath{
    VcashSecretKey* secretKey = [self deriveKey:amount andKeypath:keypath];
    NSData* commit = [_secp commitment:amount withKey:secretKey];
    return commit;
}

-(VcashSecretKey*)createNonce:(NSData*)commitment {
    VcashSecretKey* rootKey = [self deriveKey:0 andKeypath:[self rootKeyPath]];
    uint8_t ret[SECRET_KEY_SIZE];
    if( blake2b( ret, rootKey.data.bytes, commitment.bytes, SECRET_KEY_SIZE, SECRET_KEY_SIZE, PEDERSEN_COMMITMENT_SIZE ) < 0)
    {
        return nil;
    }
    NSData* keydata = [NSData dataWithBytes:ret length:SECRET_KEY_SIZE];
    return [[VcashSecretKey alloc] initWithData:keydata];
}

#pragma proof

-(NSData*)createRangeProof:(uint64_t)amount withKeyPath:(VcashKeychainPath*)path{
    NSData* commit = [self createCommitment:amount andKeypath:path];
    VcashSecretKey* secretKey = [self deriveKey:amount andKeypath:path];
    VcashSecretKey* nounce = [self createNonce:commit];
    NSData* rangeProof = [_secp createBulletProof:amount key:secretKey nounce:nounce andMessage:path.pathData];
    return rangeProof;
}

-(BOOL)verifyProof:(NSData*)commitment withProof:(NSData*)proof{
    return [_secp verifyBulletProof:commitment withProof:proof];
}

-(VcashProofInfo*)rewindProof:(NSData*)commitment withProof:(NSData*)proof{
    VcashSecretKey* nounce = [self createNonce:commitment];
    VcashProofInfo* proofInfo = [_secp rewindBulletProof:commitment nounce:nounce withProof:proof];
    return proofInfo;
}

#pragma private method
-(VcashKeychainPath*)rootKeyPath{
    return [[VcashKeychainPath alloc] initWithDepth:0 d0:0 d1:0 d2:0 d3:0];
}

@end
