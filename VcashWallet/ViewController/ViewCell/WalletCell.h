//
//  WalletCell.h
//  PoolinWallet
//
//  Created by jia.zhou on 2018/8/3.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VcashTxLog;

@interface WalletCell : UITableViewCell


- (void)setTxLog:(VcashTxLog *)txLog;

@end
