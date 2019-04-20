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

- (id) initWithDepth:(unsigned char)depth andPathData:(NSData*)pathdata;

@property (readonly, nonatomic, strong)NSString* pathStr;

@end

NS_ASSUME_NONNULL_END
