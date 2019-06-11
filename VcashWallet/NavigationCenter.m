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
#import "VcashNavigationViewController.h"
#import "SettingViewController.h"

static UINavigationController* curNavVC;

@implementation NavigationCenter

+(void)showWelcomePage
{
    VcashNavigationViewController* nav = [[VcashNavigationViewController alloc] init];
    WelcomePageViewController* welcomeVc = [[WelcomePageViewController alloc] init];
    nav.viewControllers = @[welcomeVc];
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    keyWindow.rootViewController = nav;
    curNavVC = nav;
}

+(void)showWalletPage:(BOOL)isRecover
{
   WalletViewController* welcomeVc = [[WalletViewController alloc] init];
    if (curNavVC) {
        curNavVC.viewControllers = @[welcomeVc];
    }else{
        
        VcashNavigationViewController* nav = [[VcashNavigationViewController alloc] init];
        welcomeVc.enterInRecoverMode = isRecover;
        nav.viewControllers = @[welcomeVc];
        UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
        keyWindow.rootViewController = nav;
        curNavVC = nav;
    }
  
}

+(void)showPasswordVerifyPage
{
    PinVerifyViewController* vc = [PinVerifyViewController new];
    if (curNavVC)
    {
        curNavVC.viewControllers = @[vc];
    }
    else
    {
        VcashNavigationViewController* nav = [[VcashNavigationViewController alloc] initWithRootViewController:vc];
        UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
        keyWindow.rootViewController = nav;
    }
}

+ (void)showSettingVcPage{
      SettingViewController *settingVc = [[SettingViewController alloc] init];
    if (curNavVC) {
        curNavVC.viewControllers = @[settingVc];
    }else{
        VcashNavigationViewController* nav = [[VcashNavigationViewController alloc] initWithRootViewController:settingVc];
        UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
        keyWindow.rootViewController = nav;
        curNavVC = nav;
    }
   
}

@end
