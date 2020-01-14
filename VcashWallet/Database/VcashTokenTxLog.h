//
//  VcashTxLog.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerType.h"

NS_ASSUME_NONNULL_BEGIN

@interface VcashTokenTxLog : BaseVcashTxLog

@property(strong, nonatomic)NSString* token_type;

@property(assign, nonatomic)uint64_t amount_credited;

@property(assign, nonatomic)uint64_t amount_debited;

@property(assign, nonatomic)uint64_t token_amount_credited;

@property(assign, nonatomic)uint64_t token_amount_debited;

@property(strong, nonatomic)NSArray<NSString*>* inputs;

@property(strong, nonatomic)NSArray<NSString*>* outputs;

@property(strong, nonatomic)NSArray<NSString*>* token_inputs;

@property(strong, nonatomic)NSArray<NSString*>* token_outputs;

-(void)appendInput:(NSString*)commitment;

-(void)appendOutput:(NSString*)commitment;

-(void)appendTokenInput:(NSString*)commitment;

-(void)appendTokenOutput:(NSString*)commitment;

@end

NS_ASSUME_NONNULL_END
