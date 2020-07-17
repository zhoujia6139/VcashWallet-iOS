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

@interface ServerTransaction : NSObject<NSCoding>

@property(strong, nonatomic) NSString* tx_id;

@property(strong, nonatomic) NSString* sender_id;

@property(strong, nonatomic) NSString* receiver_id;

@property(strong, nonatomic) NSString* slate;

@property(assign, nonatomic) ServerTxStatus status;

@property(strong, nonatomic) NSString* msg_sig;

@property(strong, nonatomic) NSString* tx_sig;

//unselialised
@property(strong, nonatomic) VcashSlate* slateObj;

@property(assign, nonatomic) BOOL isSend;




-(id)initWithSlate:(VcashSlate*)slate;

-(NSData*)msgToSign;


@end

@interface FinalizeTxInfo : NSObject

@property(strong, nonatomic) NSString* tx_id;

@property(assign, nonatomic) ServerTxStatus code;

@property(strong, nonatomic) NSString* msg_sig;

-(NSData*)msgToSign;

@end

NS_ASSUME_NONNULL_END
