//
//  RecoverMnemonicViewController.h
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/1.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "BaseViewController.h"

@interface RecoverMnemonicViewController : BaseViewController

@property (nonatomic, assign) BOOL recoveryPhrase;

- (void)setMnemonicKey:(NSString *)key;

@end
