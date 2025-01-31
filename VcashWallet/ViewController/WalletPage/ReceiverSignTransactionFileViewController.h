//
//  ReceiverSignTransactionFileViewController.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/6/21.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "BaseViewController.h"

@class VcashSlate;

NS_ASSUME_NONNULL_BEGIN

@interface ReceiverSignTransactionFileViewController : BaseViewController

@property (nonatomic, strong) BaseVcashTxLog *txLog;

@property (nonatomic, assign) BOOL showDone;

@end

NS_ASSUME_NONNULL_END
