//
//  VcashTypes.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/22.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VcashOutput.h"
#import "VcashSlate.h"

NS_ASSUME_NONNULL_BEGIN


@class VcashKeychainPath,VcashSecretKey;

@interface VcashProofInfo : NSObject

@property(assign, nonatomic)BOOL isSuc;

@property(assign, nonatomic)uint64_t value;

@property(strong, nonatomic)VcashSecretKey* secretKey;

@property(strong, nonatomic)NSData* message;

@end



NS_ASSUME_NONNULL_END
