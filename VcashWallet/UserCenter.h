//
//  UserCenter.h
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/16.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserCenter : NSObject

+ (instancetype)sharedInstance;

-(NSString*)getStoredMnemonicWordsWithKey:(NSString*)key;

-(void)storeMnemonicWords:(NSString*)words withKey:(NSString*)key;

-(BOOL)checkUserHaveWallet;

-(void)clearWallet;

- (void)writeAppInstallAndCreateWallet:(BOOL)installAndCreateWallet;

- (BOOL)appInstallAndCreateWallet;

- (void)writeRecoverStatusWithFailed:(BOOL)failed;

- (BOOL)recoverFailed;



@end
