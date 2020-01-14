//
//  AppDelegate.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/18.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "AppDelegate.h"
#import "NodeApi.h"
#import "ServerTxManager.h"
#import "LockScreenTimeService.h"
#import <UIView+Toast.h>
#import <IQKeyboardManager.h>
#import "WalletWrapper.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self initLoger];
    [IQKeyboardManager sharedManager].enable = YES;
    [CSToastManager setDefaultPosition:CSToastPositionCenter];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    if ([[UserCenter sharedInstance] checkUserHaveWallet])
    {
        if ([[UserCenter sharedInstance] appInstallAndCreateWallet]) {
            if ([[UserCenter sharedInstance] recoverFailed]) {
                [NavigationCenter showWelcomePage];
            }else{
                [NavigationCenter showPasswordVerifyPage];
                [[LockScreenTimeService shareInstance] addObserver];
            }
           
        }else{
            [[UserCenter sharedInstance] clearWallet];
             [NavigationCenter showWelcomePage];
        }
    }
    else
    {
        [NavigationCenter showWelcomePage];
    }
    
    [[NodeApi shareInstance] getChainHeightWithComplete:nil];
    [WalletWrapper initTokenInfos];
    
    return YES;
}

-(void)initLoger
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
    fileLogger.maximumFileSize = 10 * 1024 * 1024;
    //fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 3;
    [DDLog addLogger:fileLogger];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}


@end
