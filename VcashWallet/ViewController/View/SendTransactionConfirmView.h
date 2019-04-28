//
//  SendTransactionConfirmView.h
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/30.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendTransactionConfirmView : UIView

-(void)setReceiverId:(NSString*)receiverId andSlate:(VcashSlate*)slate;

@end
