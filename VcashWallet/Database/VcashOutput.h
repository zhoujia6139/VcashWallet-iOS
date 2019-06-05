//
//  VcashOutput.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum  {
    /// Unconfirmed
    Unconfirmed = 0,
    /// Unspent
    Unspent,
    /// Locked
    Locked,
    /// Spent
    Spent,
}OutputStatus;

@class VcashSecretKey;

@interface VcashOutput : NSObject

@property(strong, nonatomic)NSString* commitment;

@property(strong, nonatomic)NSString* keyPath;

@property(assign, nonatomic)uint64_t mmr_index;

@property(assign, nonatomic)uint64_t value;

@property(assign, nonatomic)uint64_t height;

@property(assign, nonatomic)uint64_t lock_height;

@property(assign, nonatomic)BOOL is_coinbase;

@property(assign, nonatomic)OutputStatus status;

@property(assign, nonatomic)uint32_t tx_log_id;

-(BOOL)isSpendable;

@end

NS_ASSUME_NONNULL_END
