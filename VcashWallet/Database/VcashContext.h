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

@property(strong, nonatomic)VcashSecretKey* token_sec_key;

@property(strong, nonatomic)VcashSecretKey* sec_nounce;

@property(strong, nonatomic)NSString* slate_id;

@end

NS_ASSUME_NONNULL_END
