//
//  VcashKeyChain.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/19.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VcashSecretKey.h"
#import "CoreBitcoin.h"
#import "VcashKeychainPath.h"
#import "VcashTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface VcashKeyChain : NSObject

- (id) initWithMnemonic:(BTCMnemonic*)mnemonic;

-(NSData*)createCommitment:(uint64_t)amount andKeypath:(VcashKeychainPath*)keypath;

-(VcashSecretKey*)deriveKey:(uint64_t)amount andKeypath:(VcashKeychainPath*)keypath;

-(VcashSecretKey*)createNonce:(NSData*)commitment;

#pragma proof

-(NSData*)createRangeProof:(uint64_t)amount withKeyPath:(VcashKeychainPath*)path;

-(BOOL)verifyProof:(NSData*)commitment withProof:(NSData*)proof;

-(VcashProofInfo*)rewindProof:(NSData*)commitment withProof:(NSData*)proof;

@end

NS_ASSUME_NONNULL_END
