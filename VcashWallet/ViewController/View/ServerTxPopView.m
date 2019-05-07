//
//  ServerTxPopView.m
//  VcashWallet
//
//  Created by jia zhou on 2019/5/7.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "ServerTxPopView.h"

@interface ServerTxPopView()
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *feeLabel;

@end

@implementation ServerTxPopView

-(void)setServerTx:(ServerTransaction*)tx{
    _serverTx = tx;
    if (tx.isSend){
        self.userLabel.text = [NSString stringWithFormat:@"Receiver:%@", tx.receiver_id];
    }
    else{
        self.userLabel.text = [NSString stringWithFormat:@"Sender:%@", tx.sender_id];
    }
    
    self.amountLabel.text = [NSString stringWithFormat:@"Amount:%@", @([WalletWrapper nanoToVcash:tx.slateObj.amount]).p9fString];
    
    self.feeLabel.text = [NSString stringWithFormat:@"Fee:%@", @([WalletWrapper nanoToVcash:tx.slateObj.fee]).p9fString];
}

- (IBAction)clickConfirm:(id)sender {
    if (self.serverTx.isSend){
        BOOL yesOrNo = [WalletWrapper finalizeTransaction:self.serverTx];
        if (yesOrNo){
            [MBHudHelper showTextTips:@"处理成功" onView:nil withDuration:1];
        }
    }
    else{
        BOOL yesOrNo = [WalletWrapper receiveTransaction:self.serverTx];
        if (yesOrNo){
            [MBHudHelper showTextTips:@"处理成功" onView:nil withDuration:1];
        }
    }
    
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
