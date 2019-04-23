//
//  VcashSlate.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VcashTransaction.h"

NS_ASSUME_NONNULL_BEGIN

@interface VcashSlate : NSObject

@property(strong, nonatomic)NSString* uuid;

@property(assign, nonatomic)uint16_t num_participants;

@property(assign, nonatomic)uint64_t amount;

@property(assign, nonatomic)uint64_t fee;

@property(assign, nonatomic)uint64_t height;

@property(assign, nonatomic)uint64_t lock_height;

@property(assign, nonatomic)uint64_t version;

@property(strong, nonatomic)VcashTransaction* tx;

-(void)addTxElement:(NSArray*)outputs change:(uint64_t)change;

@end

NS_ASSUME_NONNULL_END
