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
#import "LeftMenuManager.h"
#import "AddressBookViewController.h"

static UINavigationController* curNavVC;

@interface NavigationCenter ()

@property (nonatomic, strong) WalletViewController *walletVc;

@property (nonatomic, strong) SettingViewController *settingVc;

@property (nonatomic, strong) AddressBookViewController *addressBookVc;

@end

@implementation NavigationCenter

+ (id)shareInstance{
    static NavigationCenter *center = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[NavigationCenter alloc] init];
    });
    return center;
}

+(void)showWelcomePage
{
    VcashNavigationViewController* nav = [[VcashNavigationViewController alloc] init];
    WelcomePageViewController* welcomeVc = [[WelcomePageViewController alloc] init];
    nav.viewControllers = @[welcomeVc];
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    keyWindow.rootViewController = nav;
    curNavVC = nav;
}

- (void)leftMenuSwitchWalltetPage{
    curNavVC.viewControllers = @[self.walletVc];
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    keyWindow.rootViewController = curNavVC;
}

+(void)showWalletPage:(BOOL)isRecover createNewWallet:(BOOL)createNewWallet
{
   WalletViewController* welcomeVc = [[WalletViewController alloc] init];
    [[NavigationCenter shareInstance] setWalletVc:welcomeVc];
   VcashNavigationViewController* nav = [[VcashNavigationViewController alloc] init];
   welcomeVc.enterInRecoverMode = isRecover;
    welcomeVc.createNewWallet = createNewWallet;
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
    if (![[NavigationCenter shareInstance] settingVc]) {
        if (curNavVC) {
            curNavVC.viewControllers = @[settingVc];
        }else{
            VcashNavigationViewController* nav = [[VcashNavigationViewController alloc] initWithRootViewController:settingVc];
            UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
            keyWindow.rootViewController = nav;
            curNavVC = nav;
        }
    }else{
        curNavVC.viewControllers = @[[[NavigationCenter shareInstance] settingVc]];
        UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
        keyWindow.rootViewController = curNavVC;
    }
}

+ (void)showAddressBookVcPage{
    AddressBookViewController *addressBookVc = [[AddressBookViewController alloc] init];
    if (![[NavigationCenter shareInstance] addressBookVc]) {
        if (curNavVC) {
            curNavVC.viewControllers = @[addressBookVc];
        }else{
            VcashNavigationViewController* nav = [[VcashNavigationViewController alloc] initWithRootViewController:addressBookVc];
            UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
            keyWindow.rootViewController = nav;
            curNavVC = nav;
        }
    }else{
        curNavVC.viewControllers = @[[[NavigationCenter shareInstance] addressBookVc]];
        UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
        keyWindow.rootViewController = curNavVC;
    }
}

@end
