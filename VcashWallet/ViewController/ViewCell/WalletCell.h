//
//  WalletCell.h
//  PoolinWallet
//
//  Created by jia.zhou on 2018/8/3.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"

@class VcashTxLog,ServerTransaction;

@interface WalletCell : BaseTableViewCell


- (void)setServerTransaction:(ServerTransaction *)serverTx;

- (void)setTxLog:(BaseVcashTxLog *)txLog;


@end
