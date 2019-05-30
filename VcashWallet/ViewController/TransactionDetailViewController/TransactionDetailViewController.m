//
//  TransactionDetailViewController.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/27.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "TransactionDetailViewController.h"
#import "ServerType.h"

@interface TransactionDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageViewTxStatus;

@property (weak, nonatomic) IBOutlet UILabel *labelTxStatus;


@property (weak, nonatomic) IBOutlet UILabel *labelTxid;

@property (weak, nonatomic) IBOutlet UILabel *labelSender;

@property (weak, nonatomic) IBOutlet UILabel *labelRecipient;

@property (weak, nonatomic) IBOutlet UILabel *labelAmount;

@property (weak, nonatomic) IBOutlet UILabel *labelFee;


@property (weak, nonatomic) IBOutlet UILabel *labelTxTime;

@property (weak, nonatomic) IBOutlet VcashButton *btnSignature;

@property (weak, nonatomic) IBOutlet VcashButton *btnCancelTx;

@end

@implementation TransactionDetailViewController{
    UIImage *imageTxStatus;
    NSString *txStatus;
    NSString *tx_id;
    NSString *sender_id;
    NSString *receiver_id;
    uint64_t amount;
    uint64_t fee;
    uint64_t create_time;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configView];
}

- (void)configView{
    self.title = [LanguageService contentForKey:@"txDetailTitle"];
    ViewRadius(self.btnSignature, 4.0f);
    ViewBorderRadius(self.btnCancelTx, 4.0, 1.0, [UIColor colorWithHexString:@"#FF3333"]);
    

    if (self.serverTx) {
         self.btnSignature.localTitle = self.serverTx.isSend ? @"verifySign" :  @"reveiveSign";
         self.btnCancelTx.hidden = !self.serverTx.isSend;
        switch (self.serverTx.status) {
            case TxDefaultStatus:{
                //default status
                imageTxStatus = [UIImage imageNamed:@"ongoingdetail.png"];
                txStatus = self.serverTx.isSend ? @"Tx Status: waiting for the sender to sign" : @"Tx Status: waiting for the recipient to sign";
                self.btnSignature.hidden = NO;
            }
                break;
            case TxFinalized:{
                imageTxStatus = [UIImage imageNamed:@"confirmdetail.png"];
                txStatus = @"Tx Status: transaction completed";
                self.btnSignature.hidden = YES;
                self.btnCancelTx.hidden = YES;
            }
                break;
                
            case TxReceiverd:{
                //The recipient has already signed, waiting for the sender to broadcast
                imageTxStatus = [UIImage imageNamed:@"ongoingdetail.png"];
                txStatus = self.serverTx.isSend ? @"Tx Status: waiting for the sender to sign" : @"Tx Status: waiting for the recipient to sign";
            }
                break;
                
            case TxCanceled:{
                imageTxStatus = [UIImage imageNamed:@"canceldetail.png"];
                txStatus = @"Tx Status: transaction canceled";
                self.btnSignature.hidden = YES;
                [self.btnCancelTx setImage:[UIImage imageNamed:@"Delete the transaction"] forState:UIControlStateNormal];
            }
                break;
                
                
            default:
                break;
        }
        tx_id = self.serverTx.tx_id;
        sender_id = self.serverTx.sender_id;
        receiver_id = self.serverTx.receiver_id;
        amount = self.serverTx.slateObj.amount;
        fee = self.serverTx.slateObj.fee;
    }
    
    if (self.txLog) {
        if (self.txLog.tx_type == TxSent) {
            self.btnSignature.localTitle =  @"verifySign";
            self.btnCancelTx.hidden = NO;
        }else if (self.txLog.tx_type == TxReceived){
            //The recipient has already signed
            self.btnSignature.hidden = YES;
//            self.btnSignature.localTitle  = @"reveiveSign";
            self.btnCancelTx.hidden = YES;
        }
        
        switch (self.txLog.confirm_state) {
            case DefaultState:{
                if (self.txLog.tx_type == TxSent) {
                    txStatus = @"Tx Status: waiting for the recipient to sign";
                    self.btnSignature.hidden = NO;
                    self.btnCancelTx.hidden = NO;
                }else if (self.txLog.tx_type == TxReceived){
                    //The recipient has already signed
                    txStatus = @"Tx Status: waiting for the sender to sign";
                   
                }
            }
                break;
            case LoalConfirmed:{
                //tx has benn post, but not confirm by node
                
            }
                
                break;
            case NetConfirmed:{
                //confirm by node
                imageTxStatus = [UIImage imageNamed:@"confirmdetail.png"];
                txStatus = @"Tx Status: transaction completed";
                self.btnSignature.hidden = YES;
                self.btnCancelTx.hidden = YES;
               
            }
                break;
                
            default:
                break;
        }
        tx_id = (self.txLog.tx_slate_id ? self.txLog.tx_slate_id :  @"unreachable");
        [self configInfoFromTx_type:self.txLog.tx_type];
        amount = llabs((int64_t)self.txLog.amount_credited - (int64_t)self.txLog.amount_debited);
        fee = self.txLog.fee;
        create_time = self.txLog.create_time;
    }
    
    
    self.labelTxStatus.text = txStatus;
    self.imageViewTxStatus.image = imageTxStatus;
    self.labelTxid.text = tx_id;
    self.labelSender.text = sender_id;
    self.labelRecipient.text = receiver_id;
    self.labelAmount.text = [NSString stringWithFormat:@"%@ Vcash", @([WalletWrapper nanoToVcash:amount]).p9fString];
    self.labelFee.text = [NSString stringWithFormat:@"%@ Vcash", @([WalletWrapper nanoToVcash:fee]).p9fString];
    self.labelTxTime.text = create_time > 0 ? [[NSDate dateWithTimeIntervalSince1970:create_time] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"] : [[NSDate date] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}


- (void)configInfoFromTx_type:(TxLogEntryType)tx_type{
    switch (tx_type) {
        case ConfirmedCoinbase:{
            tx_id = @"coinbase";
        }
            break;
        case TxReceived:{
            sender_id = @"";
            receiver_id = [VcashWallet shareInstance].userId;
            
        }
            break;
        case TxSent:{
            sender_id =  [VcashWallet shareInstance].userId;
            receiver_id = @"";
        }
            break;
            
        case TxReceivedCancelled:{
            sender_id = @"";
            receiver_id = [VcashWallet shareInstance].userId;
        }
            break;
        case TxSentCancelled:{
            sender_id =  [VcashWallet shareInstance].userId;
            receiver_id = @"";
        }
            break;
        default:
            break;
    }
}


- (IBAction)clickedBtnSignature:(id)sender {
    [MBHudHelper startWorkProcessWithTextTips:@""];
    
    if (self.serverTx) {
        if (self.serverTx.isSend){
            [WalletWrapper finalizeTransaction:self.serverTx withComplete:^(BOOL yesOrNo, id _Nullable data){
                [MBHudHelper endWorkProcessWithSuc:yesOrNo andTextTips:data];
            }];
        }
        else{
            [WalletWrapper receiveTransaction:self.serverTx withComplete:^(BOOL yesOrNo, id _Nullable data) {
                [MBHudHelper endWorkProcessWithSuc:yesOrNo andTextTips:data];
            }];
        }
    }
    
}


- (IBAction)clickedBtnCancelTx:(id)sender {
    
    if (self.txLog) {
            switch (self.txLog.tx_type) {
                case TxSent:{
                    //sent
                    switch (self.txLog.confirm_state) {
                        case DefaultState:{
                            //cancle tx
                            [self cancleTxWith:self.txLog];
                         }
                            break;
                            
                        default:
                            break;
                    }
                }
                    break;
                    
                    break;
                    
                default:
                    break;
            }
        
        
    }
    
    if(self.serverTx){
        if (self.serverTx.status == TxCanceled) {
            //delete the transaction
            
        }else{
            //cancel the transaction
            
        }
    }
    
   
}

- (void)cancleTxWith:(VcashTxLog *)txlog{
    if ([WalletWrapper cancelTransaction:txlog]){
        [MBHudHelper showTextTips:@"Tx cancel suc" onView:nil withDuration:1];
    }
    else{
        [MBHudHelper showTextTips:@"Tx cancel failed" onView:nil withDuration:1];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
