//
//  AddressBookCell.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/7/12.
//  Copyright © 2019 blockin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressBookModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddressBookCell : UITableViewCell

@property (nonatomic, strong) AddressBookModel *model;

@end

NS_ASSUME_NONNULL_END
