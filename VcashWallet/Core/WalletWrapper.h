//
//  WalletWrapper.h
//  PoolinWallet
//
//  Created by jia zhou on 2018/7/31.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NodeApi.h"
#import "VcashTypes.h"

@interface WalletWrapper : NSObject

//得到所有合法的助记词
+(NSArray*)getAllPhraseWords;

//获取助记词
+(NSArray*)generateMnemonicPassphrase;

//根据助记词和子账户密码生成Wallet
+(BOOL)createWalletWithPhrase:(NSArray*)wordsArr nickname:(NSString*)nickname password:(NSString*)password;

//退出钱包
+(void)clearWallet;

//重置钱包
+(void)checkWalletUtxoWithComplete:(RequestCompleteBlock)block;

//创建发币交易 TODO 支持给多人发送
+(VcashSlate*)createSendTransaction:(NSString*)targetUserId amount:(uint64_t)amount fee:(uint64_t)fee withComplete:(RequestCompleteBlock)block;

//发送发币交易
+(void)sendTransaction:(VcashSlate*)slate;

//收币

//确认交易

@end
