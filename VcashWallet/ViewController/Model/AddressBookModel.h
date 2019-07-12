//
//  AddressBookModel.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/7/12.
//  Copyright © 2019 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddressBookModel : NSObject<YYModel,NSCoding>

@property (nonatomic, strong) NSString *remarkName;

@property (nonatomic, strong) NSString *address;

@end

NS_ASSUME_NONNULL_END
