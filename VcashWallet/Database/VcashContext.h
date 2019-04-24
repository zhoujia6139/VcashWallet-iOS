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

@interface VcashContext : NSObject

@property(strong, nonatomic)VcashSecretKey* sec_key;

@property(strong, nonatomic)VcashSecretKey* sec_nounce;

@property(strong, nonatomic)NSDictionary* output_ids;

@property(strong, nonatomic)NSArray* input_ids;

@property(assign, nonatomic)uint64_t fee;

@end

NS_ASSUME_NONNULL_END
