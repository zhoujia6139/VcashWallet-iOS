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
#import "VcashTxLog.h"
#import "VcashContext.h"



NS_ASSUME_NONNULL_BEGIN

@interface VcashDataManager : NSObject

+ (instancetype)shareInstance;

-(void)clearAllData;

//wallet info
-(BOOL)saveWalletInfo:(VcashWalletInfo*)info;

-(VcashWalletInfo*)loadWalletInfo;

//utxo
-(BOOL)saveOutputData:(NSArray*)arr;

-(NSArray*)getActiveOutputData;

//transaction
-(BOOL)saveTxDataArr:(NSArray*)arr;

-(BOOL)saveTx:(VcashTxLog*)txLog;

- (BOOL)deleteTxBySlateId:(NSString *)slate_id;

-(VcashTxLog*)getTxBySlateId:(NSString*)slate_id;

-(NSArray*)getTxData;

//context
-(BOOL)saveContext:(VcashContext*)context;

-(VcashContext*)getContextBySlateId:(NSString*)slateid;



//database transaction
-(BOOL)beginDatabaseTransaction;

-(BOOL)commitDatabaseTransaction;

-(BOOL)rollbackDataTransaction;

@end

NS_ASSUME_NONNULL_END
