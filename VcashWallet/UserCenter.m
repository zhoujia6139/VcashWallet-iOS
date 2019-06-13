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

#define storageAppInstallAndCreateWalletPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"appInstallAndCreateWalletPath"]
#define storageRecoverStatusPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"storageRecoverStatusPath"]

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
}

- (void)writeAppInstallAndCreateWallet:(BOOL)installAndCreateWallet{
    NSURL *url = [NSURL URLWithString:storageAppInstallAndCreateWalletPath];
    NSError *error = nil;
    BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if (!success) {
        DDLogError(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
    }
   BOOL  writeSuc = [NSKeyedArchiver archiveRootObject:@(installAndCreateWallet) toFile:storageAppInstallAndCreateWalletPath];
    if (!writeSuc) {
        DDLogError(@"write Failed");
    }
}

- (BOOL)appInstallAndCreateWallet{
    return [[NSKeyedUnarchiver unarchiveObjectWithFile:storageAppInstallAndCreateWalletPath] boolValue];;
}

- (void)writeRecoverStatusWithFailed:(BOOL)failed{
   BOOL writeSucc = [NSKeyedArchiver archiveRootObject:@(failed) toFile:storageRecoverStatusPath];
    if (!writeSucc) {
          DDLogError(@"recoverStatus write Failed");
    }
}

- (BOOL)recoverFailed{
    return  [[NSKeyedUnarchiver unarchiveObjectWithFile:storageRecoverStatusPath] boolValue];
}

@end
