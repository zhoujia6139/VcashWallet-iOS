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

@property (nonatomic, strong) BaseVcashTxLog *txLog;

@property (weak, nonatomic) IBOutlet UILabel *labelTxId;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewRadiusType;

@property (weak, nonatomic) IBOutlet UILabel *unit;

@property (weak, nonatomic) IBOutlet YYAnimatedImageView *imageViewInputOrOutput;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewState;

@property (weak, nonatomic) IBOutlet UILabel *labelAmount;

@property (weak, nonatomic) IBOutlet UILabel *labelTime;

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (nonatomic, strong) CAShapeLayer *maskLayer;

@property (nonatomic, strong) YYImage *imageSent;

@property (nonatomic, strong) YYImage *imageReceive;


@end

@implementation WalletCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
   
//    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [AppHelper addLineWithParentView:self];
    self.imageSent = [YYImage imageNamed:@"sendgif"];
    self.imageReceive = [YYImage imageNamed:@"receivegif"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setServerTransaction:(ServerTransaction *)serverTx{
    _serverTx = serverTx;
    self.labelTxId.text = serverTx.tx_id;
    serverTx.isSend ? [self.imageViewInputOrOutput setImage:self.imageSent] :[self.imageViewInputOrOutput setImage:self.imageReceive];
    int64_t amount = serverTx.slateObj.amount;
    NSString *amountStr = @([WalletWrapper nanoToVcash:amount]).p09fString;
    NSMutableAttributedString *amountAttribute = [[NSMutableAttributedString alloc] initWithString:amountStr attributes:@{NSFontAttributeName:[UIFont robotoRegularWithSize:15]}];
    if (!serverTx.isSend) {
        [amountAttribute insertAttributedString:[[NSAttributedString alloc] initWithString:@"+" attributes:@{NSFontAttributeName:[UIFont robotoBoldWithSize:15]}] atIndex:0];
    }else{
        [amountAttribute insertAttributedString:[[NSAttributedString alloc] initWithString:@"-" attributes:@{NSFontAttributeName:[UIFont robotoBoldWithSize:15]}] atIndex:0];
    }
    self.labelAmount.attributedText = amountAttribute;
    self.bgView.backgroundColor = [UIColor colorWithHexString:@"#F6F0E8"];
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

-(void)setTxLog:(BaseVcashTxLog *)txLog{
    _txLog = txLog;
    int64_t amount;
    NSString *txId = self.txLog.tx_slate_id;
    if ([txLog isKindOfClass:[VcashTxLog class]]) {
        VcashTxLog* vcLog = (VcashTxLog*)txLog;
        self.unit.text = @"V";
        amount = (int64_t)vcLog.amount_credited - (int64_t)vcLog.amount_debited;
        
        if (!txId) {
            txId = (vcLog.tx_type == ConfirmedCoinbaseOrTokenIssue) ? [LanguageService contentForKey:@"coinbase"] : [LanguageService contentForKey:@"unreachable"];
        }
    } else {
        VcashTokenTxLog* tokenLog = (VcashTokenTxLog*)txLog;
        VcashTokenInfo* tokenInfo = [WalletWrapper getTokenInfo:tokenLog.token_type];
        if (tokenInfo.Name.length <=5) {
            self.unit.text = tokenInfo.Name;
        } else {
            self.unit.text = nil;
        }
        amount = (int64_t)tokenLog.token_amount_credited - (int64_t)tokenLog.token_amount_debited;
        
        if (!txId) {
            txId = (tokenLog.tx_type == ConfirmedCoinbaseOrTokenIssue) ? [LanguageService contentForKey:@"tokenissue"] : [LanguageService contentForKey:@"unreachable"];
        }

    }
    NSString *amountStr = @([WalletWrapper nanoToVcash:amount]).p09fString;
    NSMutableAttributedString *amountAttribute = [[NSMutableAttributedString alloc] initWithString:amountStr attributes:@{NSFontAttributeName:[UIFont robotoBoldWithSize:15]}];
    
    self.labelTxId.text = txId;
    self.labelAmount.attributedText = amountAttribute;
    //    self.labelAmount.text = [NSString stringWithFormat:@"%@",amountStr];
    self.labelTime.text = [[NSDate dateWithTimeIntervalSince1970:txLog.create_time] stringWithFormat:@"yyyy-MM-dd"];
    
    switch (txLog.tx_type) {
        case ConfirmedCoinbaseOrTokenIssue:
        case TxReceived:
        case TxReceivedCancelled:
            [self.imageViewInputOrOutput setImage:[UIImage imageNamed:@"receive.png"]];
            [amountAttribute insertAttributedString:[[NSAttributedString alloc] initWithString:@"+" attributes:@{NSFontAttributeName:[UIFont robotoBoldWithSize:15]}] atIndex:0];
            break;
        case TxSent:
        case TxSentCancelled:
            [self.imageViewInputOrOutput setImage:[UIImage imageNamed:@"send.png"]];
            break;
        default:
            break;
    }
    
    switch (txLog.confirm_state){
        case DefaultState:
            if(txLog.tx_type == TxSentCancelled || txLog.tx_type == TxReceivedCancelled){
                //sender canceled
                self.stateLabel.text = [LanguageService contentForKey:@"canceled"];
                self.stateLabel.textColor = [UIColor colorWithHexString:@"#AEAEAE"];
                [self.imageViewState setImage:[UIImage imageNamed:@"canceled.png"]];
                self.bgView.backgroundColor = [UIColor whiteColor];
            }else if(txLog.tx_type == TxSent || txLog.tx_type == TxReceived){
                self.stateLabel.text = (txLog.tx_type == TxSent)  ? [LanguageService contentForKey:@"waitRecipientSignature"] : [LanguageService contentForKey:@"waitSenderSignature"];
                self.stateLabel.textColor = [UIColor colorWithHexString:@"#FF3333"];
                [self.imageViewState setImage:[UIImage imageNamed:@"ongoing.png"]];
                [self.imageViewInputOrOutput setImage:(txLog.tx_type == TxSent) ? self.imageSent : self.imageReceive];
                self.bgView.backgroundColor = [UIColor colorWithHexString:@"#F6F0E8"];
            }
            break;
        case LoalConfirmed://waiting confirm
            self.stateLabel.text = [LanguageService contentForKey:@"waitingForConfirming"];
            self.stateLabel.textColor = [UIColor colorWithHexString:@"#FF3333"];
            [self.imageViewState setImage:[UIImage imageNamed:@"ongoing.png"]];
            [self.imageViewInputOrOutput setImage:(txLog.tx_type == TxSent) ? self.imageSent : self.imageReceive];
            self.bgView.backgroundColor = [UIColor colorWithHexString:@"#F6F0E8"];
            break;
        case NetConfirmed:
            self.stateLabel.text = [LanguageService contentForKey:@"confirmed"];
            self.stateLabel.textColor = [UIColor colorWithHexString:@"#AEAEAE"];
            [self.imageViewState setImage:[UIImage imageNamed:@"confirmed.png"]];
            self.bgView.backgroundColor = [UIColor whiteColor];
            break;
    }
}





@end
