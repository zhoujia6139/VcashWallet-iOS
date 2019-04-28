//
//  NavigationCenter.h
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/16.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NavigationCenter : NSObject

+(void)showWelcomePage;

+(void)showWalletPage:(BOOL)isRecover;

+(void)showPasswordVerifyPage;

@end
