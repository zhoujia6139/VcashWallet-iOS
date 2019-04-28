//
//  NavigationCenter.m
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/16.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "NavigationCenter.h"
#import "WelcomePageViewController.h"
#import "WalletViewController.h"
#import "PinVerifyViewController.h"

static UINavigationController* curNavVC;

@implementation NavigationCenter

+(void)showWelcomePage
{
    UINavigationController* nav = [[UINavigationController alloc] init];
    WelcomePageViewController* welcomeVc = [[WelcomePageViewController alloc] init];
    nav.viewControllers = @[welcomeVc];
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    keyWindow.rootViewController = nav;
    curNavVC = nav;
}

+(void)showWalletPage:(BOOL)isRecover
{
    UINavigationController* nav = [[UINavigationController alloc] init];
    WalletViewController* welcomeVc = [[WalletViewController alloc] init];
    welcomeVc.enterInRecoverMode = isRecover;
    nav.viewControllers = @[welcomeVc];
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    keyWindow.rootViewController = nav;
    curNavVC = nav;
}

+(void)showPasswordVerifyPage
{
    PinVerifyViewController* vc = [PinVerifyViewController new];
    if (curNavVC)
    {
        [curNavVC pushViewController:vc animated:YES];
    }
    else
    {
        UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
        keyWindow.rootViewController = vc;
    }
}

@end
