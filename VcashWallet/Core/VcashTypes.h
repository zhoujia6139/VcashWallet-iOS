//
//  VcashTypes.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/22.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VcashKeychainPath,VcashSecretKey;

@interface VcashProofInfo : NSObject

@property(assign, nonatomic)BOOL isSuc;

@property(assign, nonatomic)uint64_t value;

@property(strong, nonatomic)VcashSecretKey* secretKey;

@property(strong, nonatomic)NSData* message;

@end

@interface VcashOutput : NSObject

@property(strong, nonatomic)NSData* commit;

@property(strong, nonatomic)VcashKeychainPath* keyPath;

@property(assign, nonatomic)uint64_t mmr_index;

@property(assign, nonatomic)uint64_t value;

@property(assign, nonatomic)uint64_t height;

@property(assign, nonatomic)uint64_t lock_height;

@property(assign, nonatomic)BOOL is_coinbase;

@property(strong, nonatomic)VcashSecretKey* blinding;

@end

NS_ASSUME_NONNULL_END
