//
//  LeftMenuCell.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/23.
//  Copyright © 2019 blockin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class LeftMenuModel;

@interface LeftMenuCell : BaseTableViewCell

@property (nonatomic, strong) LeftMenuModel *model;


@end

NS_ASSUME_NONNULL_END
