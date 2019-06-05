//
//  SendTransactionConfirmView.m
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/30.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "SendTransactionConfirmView.h"
#import "WalletWrapper.h"

@interface SendTransactionConfirmView()
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *feeLabel;

@property (strong, nonatomic)NSString* receiverId;

@property (strong, nonatomic)VcashSlate* slate;

@end

@implementation SendTransactionConfirmView

-(void)setReceiverId:(NSString*)receiverId andSlate:(VcashSlate*)slate
{
    self.receiverId = receiverId;
    self.slate = slate;
    self.addressLabel.text = [NSString stringWithFormat:@"ReceiverId:%@", receiverId];
    self.amountLabel.text = [NSString stringWithFormat:@"Amount:%@", @([WalletWrapper nanoToVcash:slate.amount]).p09fString];
    self.feeLabel.text = [NSString stringWithFormat:@"Fee:%@", @([WalletWrapper nanoToVcash:slate.fee]).p09fString];
}

- (IBAction)clickCancel:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)clickConfirm:(id)sender {
    [WalletWrapper sendTransaction:self.slate forUser:self.receiverId withComplete:^(BOOL yesOrNo, id _Nullable data) {
        if (yesOrNo){
            [MBHudHelper showTextTips:@"Send success!" onView:nil withDuration:1];
        }
        else{
            [MBHudHelper showTextTips:[NSString stringWithFormat:@"Send failed:%@", data] onView:nil withDuration:1];
        }
    }];

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
