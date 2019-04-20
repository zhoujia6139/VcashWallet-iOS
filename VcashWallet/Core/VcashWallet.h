//
//  VcashWallet.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/20.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VcashKeyChain.h"

NS_ASSUME_NONNULL_BEGIN

@interface VcashWallet : NSObject

@property (strong, nonatomic)VcashKeyChain* mKeyChain;

@end

NS_ASSUME_NONNULL_END
