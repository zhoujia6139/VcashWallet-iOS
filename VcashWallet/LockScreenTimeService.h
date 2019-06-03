//
//  LocckScreenTimeService.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/6/3.
//  Copyright © 2019 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LockScreenTimeService : NSObject


+ (id)shareInstance;

- (void)addObserver;

- (void)writeLockScreenType:(LockScreenType)type;

- (LockScreenType)readLockScreenType;

@end

NS_ASSUME_NONNULL_END
