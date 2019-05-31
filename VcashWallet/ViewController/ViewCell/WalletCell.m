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

@property (nonatomic, strong) VcashTxLog *txLog;

@property (weak, nonatomic) IBOutlet UILabel *labelTxId;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewRadiusType;


@property (weak, nonatomic) IBOutlet UIImageView *imageViewInputOrOutput;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewState;

@property (weak, nonatomic) IBOutlet UILabel *labelAmount;

@property (weak, nonatomic) IBOutlet UILabel *labelTime;

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (nonatomic, strong) CAShapeLayer *maskLayer;

@end

@implementation WalletCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
   
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [AppHelper addLineWithParentView:self];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setTxLog:(VcashTxLog *)txLog{
    _txLog = txLog;
    switch (txLog.tx_type) {
        case ConfirmedCoinbase:
        case TxReceived:
        case TxReceivedCancelled:
            [self.imageViewInputOrOutput setImage:[UIImage imageNamed:@"receive.png"]];
            break;
        case TxSent:
        case TxSentCancelled:
            [self.imageViewInputOrOutput setImage:[UIImage imageNamed:@"send.png"]];
            break;
        default:
            break;
    }
    
    NSString *txId = self.txLog.tx_slate_id;
    if (!txId) {
        txId = (self.txLog.tx_type == ConfirmedCoinbase) ? @"coinbase" : @"unreachable";
    }
    self.labelTxId.text = txId;
    int64_t amount = (int64_t)txLog.amount_credited - (int64_t)txLog.amount_debited;
    self.labelAmount.text = [NSString stringWithFormat:@"%@",@([WalletWrapper nanoToVcash:amount]).p9fString];
    self.labelTime.text = [[NSDate dateWithTimeIntervalSince1970:txLog.create_time] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    switch (txLog.confirm_state){
        case DefaultState:
        case LoalConfirmed://waiting confirm
            if(txLog.tx_type == TxSentCancelled || txLog.tx_type == TxReceivedCancelled){
                //sender canceled
                self.stateLabel.text = @"Canceled";
                [self.imageViewState setImage:[UIImage imageNamed:@"canceled.png"]];
            }else{
                self.stateLabel.text = @"ongoing";
                [self.imageViewState setImage:[UIImage imageNamed:@"ongoing.png"]];
            }
            break;
        case NetConfirmed:
            self.stateLabel.text = @"Confirmed";
            [self.imageViewState setImage:[UIImage imageNamed:@"confirmed.png"]];
            break;
    }
}





@end
