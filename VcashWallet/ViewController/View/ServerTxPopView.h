//
//  ServerTxPopView.h
//  VcashWallet
//
//  Created by jia zhou on 2019/5/7.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerType.h"

NS_ASSUME_NONNULL_BEGIN

@interface ServerTxPopView : UIView

@property(strong, nonatomic)ServerTransaction* serverTx;

@end

NS_ASSUME_NONNULL_END
