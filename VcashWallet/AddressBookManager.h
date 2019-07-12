//
//  AddressBookManager.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/7/12.
//  Copyright © 2019 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressBookModel.h"




NS_ASSUME_NONNULL_BEGIN

@interface AddressBookManager : NSObject

+ (id)shareInstance;

- (BOOL)writeAddressBookModel:(AddressBookModel *)model;

- (BOOL)deleteAddressBookModel:(AddressBookModel *)model;

- (BOOL)isExistByAddressBookModel:(AddressBookModel *)model;

- (NSArray <AddressBookModel *> *)getAddressBook;


@end

NS_ASSUME_NONNULL_END
