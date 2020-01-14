//
//  VcashTxLog.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerType.h"
#import "BaseVcashTxLog.h"

NS_ASSUME_NONNULL_BEGIN


@interface VcashTxLog : BaseVcashTxLog

@property(assign, nonatomic)uint64_t amount_credited;

@property(assign, nonatomic)uint64_t amount_debited;

@property(strong, nonatomic)NSArray<NSString*>* inputs;

@property(strong, nonatomic)NSArray<NSString*>* outputs;

-(void)appendInput:(NSString*)commitment;

-(void)appendOutput:(NSString*)commitment;

@end

NS_ASSUME_NONNULL_END
