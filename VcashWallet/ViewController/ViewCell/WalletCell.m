//
//  WalletCell.m
//  PoolinWallet
//
//  Created by jia.zhou on 2018/8/3.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "WalletCell.h"
#import "VcashTxLog.h"
#import "NSNumber+Utils.h"

@interface WalletCell ()

@property (weak, nonatomic) IBOutlet UIButton *btnInputOrOutPut;

@property (weak, nonatomic) IBOutlet UILabel *labelAmount;

@property (weak, nonatomic) IBOutlet UILabel *labelTime;

@end

@implementation WalletCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setTxLog:(VcashTxLog *)txLog{
    _txLog = txLog;
    uint64_t amount = 0;
    switch (txLog.tx_type) {
        case ConfirmedCoinbase:
            [self.btnInputOrOutPut setTitle:@"ConfirmedCoinbase" forState:UIControlStateNormal];
            amount = txLog.amount_credited;
            break;
        case TxReceived:
            [self.btnInputOrOutPut setTitle:@"TxReceived" forState:UIControlStateNormal];
            amount = txLog.amount_credited;
            break;
        case TxSent:
            [self.btnInputOrOutPut setTitle:@"TxSent" forState:UIControlStateNormal];
            amount = txLog.amount_debited;
            break;
        case TxReceivedCancelled:
            [self.btnInputOrOutPut setTitle:@"TxReceivedCancelled" forState:UIControlStateNormal];
            amount = txLog.amount_credited;
            break;
        case TxSentCancelled:
            [self.btnInputOrOutPut setTitle:@"TxSentCancelled" forState:UIControlStateNormal];
            amount = txLog.amount_debited;
            break;
        default:
            break;
    }
    
    self.labelAmount.text = [NSString stringWithFormat:@"%@ Vcash",@([WalletWrapper nanoToVcash:amount]).p9fString];
    self.labelTime.text = [[NSDate dateWithTimeIntervalSince1970:txLog.create_time] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

@end
