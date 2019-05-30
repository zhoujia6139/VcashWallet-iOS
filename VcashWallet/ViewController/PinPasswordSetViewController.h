//
//  PinPasswordSetViewController.h
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/16.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "BaseViewController.h"

@interface PinPasswordSetViewController : BaseViewController

@property (strong, nonatomic)NSArray* mnemonicWordsArr;

@property (assign, nonatomic)BOOL isRecover;

@property (assign, nonatomic)BOOL isChangePassword;

@property (strong, nonatomic)NSString *currentPassword;


@end
