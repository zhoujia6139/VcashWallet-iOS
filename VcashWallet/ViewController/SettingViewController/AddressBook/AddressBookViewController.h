//
//  AddressBookViewController.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/7/12.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "BaseViewController.h"
#import "AddressBookModel.h"

NS_ASSUME_NONNULL_BEGIN



@protocol AddressBookViewControllerDelegate <NSObject>

- (void)selectedAddressBook:(AddressBookModel *)model;

@end

@interface AddressBookViewController : BaseViewController

@property (nonatomic, assign) BOOL fromSendTxVc;

@property (nonatomic, weak) id <AddressBookViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
