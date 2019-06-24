//
//  TransactionDetailView.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/6/21.
//  Copyright © 2019 blockin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SignCallBack)(void);

@interface TransactionDetailView : UIView

@property (nonatomic, copy) SignCallBack signCallBack;


- (void)show;

@end

NS_ASSUME_NONNULL_END
