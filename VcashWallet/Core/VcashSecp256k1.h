//
//  VcashSecp256k1.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/19.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "secp256k1.h"
#import "VcashSecretKey.h"
#import "VcashTypes.h"

NS_ASSUME_NONNULL_BEGIN

enum ContextFlag {
    ContextNone = SECP256K1_CONTEXT_NONE,
    ContextSignOnly = SECP256K1_CONTEXT_SIGN,
    ContextVerifyOnly = SECP256K1_CONTEXT_VERIFY,
    ContextCommit = (SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY)
};

@interface VcashSecp256k1 : NSObject

- (id) initWithFlag:(unsigned int)flags;

-(NSData*)blindSwitch:(uint64_t)value withKey:(VcashSecretKey*)key;

-(BOOL)verifyEcSecretKey:(NSData*)data;

-(NSData*)commitment:(uint64_t)value withKey:(VcashSecretKey*)key;

-(VcashSecretKey*)blindSumWithPositiveArr:(NSArray<NSData*>*)positive andNegative:(NSArray<NSData*>*)negative;

//secret nonce
-(VcashSecretKey*)exportSecnonceSingle;

-(NSData*)getPubkeyFormSecretKey:(VcashSecretKey*)key;

#pragma proof
-(NSData*)createBulletProof:(uint64_t)value key:(VcashSecretKey*)key nounce:(VcashSecretKey*)nounce andMessage:(NSData*)message;

-(BOOL)verifyBulletProof:(NSData*)commitment withProof:(NSData*)proof;

-(VcashProofInfo*)rewindBulletProof:(NSData*)commitment nounce:(VcashSecretKey*)nounce withProof:(NSData*)proof;

@end

NS_ASSUME_NONNULL_END
