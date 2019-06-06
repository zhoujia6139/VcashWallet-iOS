//
//  ServerTxManager.h
//  VcashWallet
//
//  Created by jia zhou on 2019/5/7.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerType.h"

NS_ASSUME_NONNULL_BEGIN

@interface ServerTxManager : NSObject

+ (instancetype)shareInstance;

-(void)startWork;

-(void)stopWork;

-(void)fetchTxStatus:(BOOL)force;

- (ServerTransaction *)getServerTxByTx_id:(NSString *)tx_id;

- (void)hiddenMsgNotificationView;


@end

NS_ASSUME_NONNULL_END