//
//  NSData+AES256.h
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/16.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSData(AES256)

-(NSData *) aes256_encrypt:(NSString *)key;

-(NSData *) aes256_decrypt:(NSString *)key;

@end
