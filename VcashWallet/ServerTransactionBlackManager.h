//
//  ServerTransactionBlackManager.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/31.
//  Copyright © 2019 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServerTransactionBlackManager : NSObject

+ (id)shareInstance;

- (BOOL)isBlackWithServerTransaction:(ServerTransaction *)serverTx;

- (void)writeBlackServerTransaction:(ServerTransaction *)serverTx;

- (NSDictionary *)readServerTransactions;


@end

NS_ASSUME_NONNULL_END
