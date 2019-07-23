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

-(BTCKey*)deriveBTCKeyWithKeypath:(VcashKeychainPath*)keypath{
    BTCKeychain* keychain = [_keyChain derivedKeychainWithPath:keypath.pathStr];
    BTCKey* key = keychain.key;
    return key;
}

-(VcashSecretKey*)deriveKey:(uint64_t)amount andKeypath:(VcashKeychainPath*)keypath andSwitchType:(SwitchCommitmentType)switchType{
    BTCKey* key = [self deriveBTCKeyWithKeypath:keypath];
    if (switchType == SwitchCommitmentTypeRegular){
        NSData* data = [_secp blindSwitch:amount withKey:[[VcashSecretKey alloc] initWithData:key.privateKey]];
        return [[VcashSecretKey alloc] initWithData:data];
    }
    else if(switchType == SwitchCommitmentTypeNone){
        return [[VcashSecretKey alloc] initWithData:key.privateKey];
    }
    else{
        return nil;
    }
}

-(NSData*)createCommitment:(uint64_t)amount andKeypath:(VcashKeychainPath*)keypath andSwitchType:(SwitchCommitmentType)switchType{
    VcashSecretKey* secretKey = [self deriveKey:amount andKeypath:keypath andSwitchType:switchType];
    NSData* commit = [_secp commitment:amount withKey:secretKey];
    return commit;
}

-(VcashSecretKey*)createNonce:(NSData*)commitment {
    VcashSecretKey* rootKey = [self deriveKey:0 andKeypath:[self rootKeyPath] andSwitchType:SwitchCommitmentTypeRegular];
    uint8_t ret[SECRET_KEY_SIZE];
    if( blake2b( ret, rootKey.data.bytes, commitment.bytes, SECRET_KEY_SIZE, SECRET_KEY_SIZE, PEDERSEN_COMMITMENT_SIZE ) < 0)
    {
        return nil;
    }
    NSData* keydata = [NSData dataWithBytes:ret length:SECRET_KEY_SIZE];
    return [[VcashSecretKey alloc] initWithData:keydata];
}

-(VcashSecretKey*)createNonceV2:(NSData*)commitment forPrivate:(BOOL)forPrivate{
    VcashSecretKey* rootKey = [self deriveKey:0 andKeypath:[self rootKeyPath] andSwitchType:SwitchCommitmentTypeNone];
    uint8_t keyHashData[SECRET_KEY_SIZE];
    if (forPrivate){
        if( blake2b( keyHashData, rootKey.data.bytes, NULL, SECRET_KEY_SIZE, SECRET_KEY_SIZE, 0 ) < 0)
        {
            return nil;
        }
    }
    else{
        NSData* rootPubkey = [_secp getPubkeyFormSecretKey:rootKey];
        NSData* compressPubkey = [_secp getCompressedPubkey:rootPubkey];
        if( blake2b( keyHashData, compressPubkey.bytes, NULL, SECRET_KEY_SIZE, compressPubkey.length, 0 ) < 0)
        {
            return nil;
        }
    }
    uint8_t ret[SECRET_KEY_SIZE];
    if( blake2b( ret, keyHashData, commitment.bytes, SECRET_KEY_SIZE, SECRET_KEY_SIZE, PEDERSEN_COMMITMENT_SIZE ) < 0)
    {
        return nil;
    }
    NSData* keydata = [NSData dataWithBytes:ret length:SECRET_KEY_SIZE];
    return [[VcashSecretKey alloc] initWithData:keydata];
}

#pragma proof

-(NSData*)createRangeProof:(uint64_t)amount withKeyPath:(VcashKeychainPath*)path{
    NSData* commit = [self createCommitment:amount andKeypath:path andSwitchType:SwitchCommitmentTypeRegular];
    VcashSecretKey* secretKey = [self deriveKey:amount andKeypath:path andSwitchType:SwitchCommitmentTypeRegular];
    VcashSecretKey* rewindNounce = [self createNonceV2:commit forPrivate:NO];
    VcashSecretKey* privateNounce = [self createNonceV2:commit forPrivate:YES];
    /// Message bytes:
    ///     0: reserved for future use
    ///     1: wallet type (0 for standard)
    ///     2: switch commitment type
    ///     3: path depth
    ///  4-19: derivation path
    uint8_t tmp[4];
    tmp[0] = 0;
    tmp[1] = 0;
    tmp[2] = SwitchCommitmentTypeRegular;
    tmp[3] = 3;
    NSMutableData* msgData = [NSMutableData dataWithBytes:tmp length:4];
    [msgData appendData:path.pathData];
    NSData* rangeProof = [_secp createBulletProof:amount key:secretKey rewindNounce:rewindNounce privateNounce:privateNounce andMessage:msgData];
    return rangeProof;
}

-(VcashProofInfo*)rewindProof:(NSData*)commitment withProof:(NSData*)proof{
    //first rewind by legacy version
    VcashSecretKey* nounce = [self createNonce:commitment];
    VcashProofInfo* proofInfo = [_secp rewindBulletProof:commitment nounce:nounce withProof:proof];
    if (!proofInfo){
        //rewind by new version
        VcashSecretKey* rewindNounce = [self createNonceV2:commitment forPrivate:NO];
        proofInfo = [_secp rewindBulletProof:commitment nounce:rewindNounce withProof:proof];
        proofInfo.version = 1;
    }
    return proofInfo;
}

#pragma private method
-(VcashKeychainPath*)rootKeyPath{
    return [[VcashKeychainPath alloc] initWithDepth:0 d0:0 d1:0 d2:0 d3:0];
}

@end
