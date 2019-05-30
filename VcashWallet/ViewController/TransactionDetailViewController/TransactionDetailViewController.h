//
//  TransactionDetailViewController.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/27.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class ServerTransaction;

@interface TransactionDetailViewController : BaseViewController

@property (nonatomic, strong) ServerTransaction  *serverTx;

@property (nonatomic, strong) VcashTxLog *txLog;



@end

NS_ASSUME_NONNULL_END
