//
//  VcashWalletInfo.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/25.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VcashWalletInfo : NSObject

@property(strong, nonatomic)NSString* curKeyPath;

@property(assign, nonatomic)uint64_t curHeight;

@property(assign, nonatomic)uint32_t curTxLogId;

@end

NS_ASSUME_NONNULL_END
