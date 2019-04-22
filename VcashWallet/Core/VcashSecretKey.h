//
//  VcashSecretKey.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/20.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VcashSecp256k1;

@interface VcashSecretKey : NSObject

- (id) initWithData:(NSData*)data andSecp:(VcashSecp256k1*)secp;

@property(readonly, strong, nonatomic)NSData* data;

@end

NS_ASSUME_NONNULL_END
