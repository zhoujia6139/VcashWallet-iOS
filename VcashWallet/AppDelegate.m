//
//  AppDelegate.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/18.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "AppDelegate.h"
#include "secp256k1.h"
#include "blake2.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    secp256k1_context* context = secp256k1_context_create(SECP256K1_CONTEXT_NONE);
    
    uint8_t key[BLAKE2B_KEYBYTES];
    uint8_t buf[10];
    
    for( size_t i = 0; i < BLAKE2B_KEYBYTES; ++i )
        key[i] = ( uint8_t )i;
    
    for( size_t i = 0; i < 10; ++i )
        buf[i] = ( uint8_t )i;
    
    for( size_t i = 0; i < 10; ++i )
    {
        uint8_t hash[64];
        
        if( blake2b( hash, buf, key, 64, i, BLAKE2B_KEYBYTES ) < 0)
        {
            puts( "error" );
        }
    }
    
    puts( "ok" );
    
    return YES;
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
}


@end
