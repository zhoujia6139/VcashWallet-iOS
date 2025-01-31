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
#import "VcashSecp256k1.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum{
    SwitchCommitmentTypeNone = 0,
    SwitchCommitmentTypeRegular = 1,
}SwitchCommitmentType;

@interface VcashKeyChain : NSObject

@property(readonly, strong, nonatomic)VcashSecp256k1* secp;

- (id) initWithMnemonic:(BTCMnemonic*)mnemonic;

-(BTCKey*)deriveBTCKeyWithKeypath:(VcashKeychainPath*)keypath;

-(VcashSecretKey*)deriveKey:(uint64_t)amount andKeypath:(VcashKeychainPath*)keypath andSwitchType:(SwitchCommitmentType)switchType;

-(NSData*)createCommitment:(uint64_t)amount andKeypath:(VcashKeychainPath*)keypath andSwitchType:(SwitchCommitmentType)switchType;

//proof
-(NSData*)createRangeProof:(uint64_t)amount withKeyPath:(VcashKeychainPath*)path;

-(VcashProofInfo*)rewindProof:(NSData*)commitment withProof:(NSData*)proof;

@end

NS_ASSUME_NONNULL_END
