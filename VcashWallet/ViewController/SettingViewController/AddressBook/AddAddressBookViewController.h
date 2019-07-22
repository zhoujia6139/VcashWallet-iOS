//
//  AddAddressBookViewController.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/7/12.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class AddressBookModel;

@protocol AddAddressBookViewControllerDelegate <NSObject>

- (void)saveSucWithAddressBookModel:(AddressBookModel *)model;

@end

@interface AddAddressBookViewController : BaseViewController

@property (nonatomic, assign) BOOL edit;

@property (nonatomic, strong) NSString *remarkName;

@property (nonatomic, strong) NSString *address;

@property (nonatomic, weak) id<AddAddressBookViewControllerDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
