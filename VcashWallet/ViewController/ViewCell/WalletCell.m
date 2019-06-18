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
#import "ServerType.h"

@interface WalletCell ()

@property (nonatomic, strong) ServerTransaction *serverTx;

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
   
//    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [AppHelper addLineWithParentView:self];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setServerTransaction:(ServerTransaction *)serverTx{
    _serverTx = serverTx;
    self.labelTxId.text = serverTx.tx_id;
    serverTx.isSend ? [self.imageViewInputOrOutput setImage:[UIImage imageNamed:@"send.png"]] :[self.imageViewInputOrOutput setImage:[UIImage imageNamed:@"receive.png"]];
    int64_t amount = serverTx.slateObj.amount;
    NSString *amountStr = @([WalletWrapper nanoToVcash:amount]).p09fString;
    if (!serverTx.isSend) {
        amountStr = [NSString stringWithFormat:@"+%@",@([WalletWrapper nanoToVcash:amount]).p09fString];
    }else{
        amountStr = [NSString stringWithFormat:@"-%@",@([WalletWrapper nanoToVcash:amount]).p09fString];
    }
    self.labelAmount.text = [NSString stringWithFormat:@"%@",amountStr];
    self.labelTime.text = [[NSDate date] stringWithFormat:@"yyyy-MM-dd"];
    [self.imageViewState setImage:[UIImage imageNamed:@"ongoing.png"]];
    self.stateLabel.textColor = [UIColor colorWithHexString:@"#FF3333"];
    switch (serverTx.status) {
        case TxDefaultStatus:{
            self.stateLabel.text = serverTx.isSend ? [LanguageService contentForKey:@"waitRecipientSignature"] : [LanguageService contentForKey:@"waitProcess"];
        }
            break;
        case TxReceived:{
            self.stateLabel.text = serverTx.isSend ? [LanguageService contentForKey:@"waitProcess"] : [LanguageService contentForKey:@"waitSenderSignature"];
        }
            break;
            
        default:
            break;
    }

}

-(void)setTxLog:(VcashTxLog *)txLog{
    _txLog = txLog;
    int64_t amount = (int64_t)txLog.amount_credited - (int64_t)txLog.amount_debited;
    NSString *amountStr = @([WalletWrapper nanoToVcash:amount]).p09fString;
    switch (txLog.tx_type) {
        case ConfirmedCoinbase:
        case TxReceived:
        case TxReceivedCancelled:
            [self.imageViewInputOrOutput setImage:[UIImage imageNamed:@"receive.png"]];
            amountStr = [NSString stringWithFormat:@"+%@",@([WalletWrapper nanoToVcash:amount]).p09fString];
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
        txId = (self.txLog.tx_type == ConfirmedCoinbase) ? [LanguageService contentForKey:@"coinbase"] : [LanguageService contentForKey:@"unreachable"];
    }
    self.labelTxId.text = txId;
    self.labelAmount.text = [NSString stringWithFormat:@"%@",amountStr];
    self.labelTime.text = [[NSDate dateWithTimeIntervalSince1970:txLog.create_time] stringWithFormat:@"yyyy-MM-dd"];
    switch (txLog.confirm_state){
        case DefaultState:
            if(txLog.tx_type == TxSentCancelled || txLog.tx_type == TxReceivedCancelled){
                //sender canceled
                self.stateLabel.text = [LanguageService contentForKey:@"canceled"];
                self.stateLabel.textColor = [UIColor colorWithHexString:@"#AEAEAE"];
                [self.imageViewState setImage:[UIImage imageNamed:@"canceled.png"]];
            }else if(txLog.tx_type == TxSent || txLog.tx_type == TxReceived){
                self.stateLabel.text = (txLog.tx_type == TxSent)  ? [LanguageService contentForKey:@"waitRecipientSignature"] : [LanguageService contentForKey:@"waitSenderSignature"];
                self.stateLabel.textColor = [UIColor colorWithHexString:@"#FF3333"];
                [self.imageViewState setImage:[UIImage imageNamed:@"ongoing.png"]];
            }
            break;
        case LoalConfirmed://waiting confirm
                self.stateLabel.text = [LanguageService contentForKey:@"waitingForConfirming"];
                self.stateLabel.textColor = [UIColor colorWithHexString:@"#FF3333"];
                [self.imageViewState setImage:[UIImage imageNamed:@"ongoing.png"]];
            break;
        case NetConfirmed:
            self.stateLabel.text = [LanguageService contentForKey:@"confirmed"];
            self.stateLabel.textColor = [UIColor colorWithHexString:@"#AEAEAE"];
            [self.imageViewState setImage:[UIImage imageNamed:@"confirmed.png"]];
            break;
    }
}





@end
