//
//  ServerType.h
//  VcashWallet
//
//  Created by jia zhou on 2019/5/6.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum{
    TxDefaultStatus = 0,
    TxReceiverd,
    TxFinalized,
    TxCanceled,
    TxClosed
}ServerTxStatus;

@class VcashSlate;

@interface ServerTransaction : NSObject

@property(strong, nonatomic) NSString* tx_id;

@property(strong, nonatomic) NSString* sender_id;

@property(strong, nonatomic) NSString* receiver_id;

@property(strong, nonatomic) NSString* slate;

@property(assign, nonatomic) ServerTxStatus status;

//unselialised
@property(strong, nonatomic) VcashSlate* slateObj;

@property(assign, nonatomic) BOOL isSend;

-(id)initWithSlate:(VcashSlate*)slate;


@end

@interface FinalizeTxInfo : NSObject

@property(strong, nonatomic) NSString* tx_id;

@property(assign, nonatomic) ServerTxStatus code;

@end

NS_ASSUME_NONNULL_END
