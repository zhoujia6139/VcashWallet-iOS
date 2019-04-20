//
//  VcashSecp256k1.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/19.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "secp256k1.h"

NS_ASSUME_NONNULL_BEGIN

@interface VcashSecp256k1 : NSObject

- (id) initWithFlag:(unsigned int)flags;

-(NSData*)blindSwitch:(uint64_t)value withKey:(NSData*)key;

@end

NS_ASSUME_NONNULL_END
