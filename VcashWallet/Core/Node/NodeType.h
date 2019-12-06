//
//  NodeType.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/22.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NodeOutput : NSObject

@property(strong, nonatomic) NSString* output_type;

@property(strong, nonatomic) NSString* token_type;

@property(strong, nonatomic) NSString* commit;

@property(assign, nonatomic) bool spent;

@property(strong, nonatomic) NSString* proof;

@property(strong, nonatomic) NSString* proof_hash;

@property(assign, nonatomic) uint64_t block_height;

@property(assign, nonatomic) uint64_t mmr_index;


@end

@interface NodeOutputs : NSObject

@property(assign, nonatomic) uint64_t highest_index;

@property(assign, nonatomic) uint64_t last_retrieved_index;

@property(strong, nonatomic) NSArray* outputs;


@end

@interface NodeChainInfo : NSObject

@property(assign, nonatomic) uint64_t height;

@property(strong, nonatomic) NSString* last_block_pushed;

@property(strong, nonatomic) NSString* prev_block_to_last;

@property(assign, nonatomic) uint64_t total_difficulty;


@end

@interface NodeRefreshOutput : NSObject

@property(assign, nonatomic) uint64_t height;

@property(strong, nonatomic) NSString* commit;

@property(assign, nonatomic) uint64_t mmr_index;


@end

@interface NodeRefreshTokenOutput : NSObject

@property(assign, nonatomic) uint64_t height;

@property(strong, nonatomic) NSString* commit;

@property(strong, nonatomic) NSString* token_type;

@property(assign, nonatomic) uint64_t mmr_index;


@end

NS_ASSUME_NONNULL_END
