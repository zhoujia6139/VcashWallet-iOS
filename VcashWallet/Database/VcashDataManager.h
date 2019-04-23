//
//  VcashDataManager.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VcashOutput.h"

NS_ASSUME_NONNULL_BEGIN

@interface VcashDataManager : NSObject

+ (instancetype)shareInstance;

//关闭数据库
-(void)closeDatabase;

//utxo
-(BOOL)saveOutputData:(NSArray*)arr;

//transaction

@end

NS_ASSUME_NONNULL_END
