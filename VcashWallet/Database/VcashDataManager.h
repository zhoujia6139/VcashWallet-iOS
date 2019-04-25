//
//  VcashDataManager.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VcashOutput.h"
#import "VcashWalletInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface VcashDataManager : NSObject

+ (instancetype)shareInstance;

-(void)closeDatabase;

//wallet info
-(BOOL)saveWalletInfo:(VcashWalletInfo*)info;

-(VcashWalletInfo*)loadWalletInfo;

//utxo
-(BOOL)saveOutputData:(NSArray*)arr;

-(NSArray*)getActiveOutputData;

//transaction

@end

NS_ASSUME_NONNULL_END
