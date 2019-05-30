//
//  VcashTextField.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/22.
//  Copyright © 2019 blockin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//IB_DESIGNABLE

@interface VcashTextField : UITextField

@property (nonatomic, strong) IBInspectable NSString *localText;

@property (nonatomic, strong) IBInspectable NSString *localPlaceholder;

@end

NS_ASSUME_NONNULL_END
