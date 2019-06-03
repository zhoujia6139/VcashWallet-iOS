//
//  UserCenter.m
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/16.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "UserCenter.h"
#import "NSString +AES256.h"

#define kKeyChainService  @"kVcashWallet"
#define kKeyChainMnemonic  @"kKeyChainMnemonic"

#define kAppInstallAndCreateWallet @"kAppInstallAndCreateWallet"

@implementation UserCenter

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static id sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(NSString*)getStoredMnemonicWordsWithKey:(NSString*)key
{
    NSString* words = [YYKeychain getPasswordForService:kKeyChainService account:kKeyChainMnemonic];
    NSString* retStr = [words aes256_decrypt:key];
    return retStr;
}

-(void)storeMnemonicWords:(NSString*)words withKey:(NSString*)key
{
    if (words)
    {
        NSString* encriptStr = [words aes256_encrypt:key];
        if (encriptStr)
        {
            [YYKeychain setPassword:encriptStr forService:kKeyChainService account:kKeyChainMnemonic];
        }
    }
    else
    {
        [YYKeychain deletePasswordForService:kKeyChainService account:kKeyChainMnemonic];
    }
}

-(BOOL)checkUserHaveWallet
{
    NSString* words = [YYKeychain getPasswordForService:kKeyChainService account:kKeyChainMnemonic];
    if (words)
    {
        return YES;
    }
    
    return NO;
}

-(void)clearWallet
{
    [YYKeychain deletePasswordForService:kKeyChainService account:kKeyChainMnemonic];
    //[WalletWrapper clearWallet];
}

- (void)writeAppInstallAndCreateWallet:(BOOL)installAndCreateWallet{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@(installAndCreateWallet) forKey:kAppInstallAndCreateWallet];
    [userDefault synchronize];
}

- (BOOL)appInstallAndCreateWallet{
     NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [[userDefault objectForKey:kAppInstallAndCreateWallet] boolValue];
}


@end
