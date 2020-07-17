//
//  VcashContext.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VcashSecretKey.h"

NS_ASSUME_NONNULL_BEGIN

@interface VcashCommitId : NSObject

@property(strong, nonatomic)NSString* keyPath;

@property(strong, nonatomic)NSNumber* mmr_index;

@property(assign, nonatomic)uint64_t value;

@end

@interface VcashContext : NSObject

@property(strong, nonatomic)VcashSecretKey* sec_key;

@property(strong, nonatomic)VcashSecretKey* token_sec_key;

@property(strong, nonatomic)VcashSecretKey* sec_nounce;

@property(strong, nonatomic)NSString* slate_id;

@property(assign, nonatomic)uint64_t amount;

@property(assign, nonatomic)uint64_t fee;

@property(strong, nonatomic)NSMutableArray<VcashCommitId*>* output_ids;

@property(strong, nonatomic)NSMutableArray<VcashCommitId*>* input_ids;

@property(strong, nonatomic)NSMutableArray<VcashCommitId*>* token_output_ids;

@property(strong, nonatomic)NSMutableArray<VcashCommitId*>* token_input_ids;

@end

NS_ASSUME_NONNULL_END
