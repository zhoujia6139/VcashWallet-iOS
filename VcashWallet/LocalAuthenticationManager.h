//
//  LocalAuthenticationManager.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/7/15.
//  Copyright © 2019 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LocalAuthentication/LocalAuthentication.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocalAuthenticationManager : NSObject

+ (id)shareInstance;

- (BOOL)supportTouchIDOrFaceID;

- (void)saveEnableAuthentication:(BOOL)enable;

- (BOOL)getEnableAuthentication;

- (void)verifyIdentidyWithComplete:(void(^)(BOOL success, NSError * __nullable error))complete;

@end

NS_ASSUME_NONNULL_END
