//
//  WalletWrapper.h
//  PoolinWallet
//
//  Created by jia zhou on 2018/7/31.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NodeApi.h"

@interface WalletWrapper : NSObject

//得到所有合法的助记词
+(NSArray*)getAllPhraseWords;

//获取助记词
+(NSArray*)generateMnemonicPassphrase;

//根据助记词和子账户密码生成Wallet
+(BOOL)createWalletWithPhrase:(NSArray*)wordsArr nickname:(NSString*)nickname password:(NSString*)password;

//重置退出钱包
+(void)clearWallet;

+(void)checkWalletUtxoWithComplete:(RequestCompleteBlock)block;

@end
