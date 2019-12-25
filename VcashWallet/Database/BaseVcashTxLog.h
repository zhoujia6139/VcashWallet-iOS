//
//  BaseVcashTxLog.h
//  VcashWallet
//
//  Created by jia zhou on 2019/12/25.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    /// local tx state
    DefaultState = 0,
    /// tx has benn post, but not confirm by node
    LoalConfirmed,
    /// confirm by node
    NetConfirmed,
}TxLogConfirmType;

@interface BaseVcashTxLog : NSObject

@property(assign, nonatomic)uint32_t tx_id;

@property(strong, nonatomic)NSString* tx_slate_id;

@property(strong, nonatomic)NSString* parter_id;

@property(assign, nonatomic)uint64_t create_time;

@property(assign, nonatomic)uint64_t confirm_time;

@property(assign, nonatomic)uint64_t confirm_height;

@property(assign, nonatomic)TxLogConfirmType confirm_state;

@property(assign, nonatomic)ServerTxStatus status;

-(BOOL)isCanBeCanneled;

-(void)cancelTxlog;

@end

NS_ASSUME_NONNULL_END
