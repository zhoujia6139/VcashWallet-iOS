//
//  VcashKeychainPath.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/20.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VcashKeychainPath : NSObject

- (id) initWithDepth:(uint8_t)depth andPathData:(NSData*)pathdata;

- (id) initWithDepth:(uint8_t)depth d0:(uint32_t)d0 d1:(uint32_t)d1 d2:(uint32_t)d2 d3:(uint32_t)d3;

- (id) initWithPathstr:(NSString*)pathStr;

@property (readonly, nonatomic, strong)NSString* pathStr;

@property (readonly, nonatomic, strong)NSData* pathData;

-(instancetype)nextPath;

@end

NS_ASSUME_NONNULL_END
