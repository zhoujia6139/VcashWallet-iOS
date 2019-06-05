//
//  TransactionDetailViewController.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/27.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "TransactionDetailViewController.h"
#import "ServerType.h"
#import "ServerTransactionBlackManager.h"
#import "ServerTxManager.h"

@interface TransactionDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageViewTxStatus;

@property (weak, nonatomic) IBOutlet UILabel *labelTxStatus;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintViewStatusWidth;


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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[ServerTxManager shareInstance] hiddenMsgNotificationView];
    if (self.isFromSendTxVc) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#EEEEEE"]] forBarMetrics:UIBarMetricsDefault];
    NSMutableArray *arrVcs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    NSInteger count = arrVcs.count;
    for (NSInteger i = count - 1; i >= 0; i--) {
        UIViewController *vc = arrVcs[i];
        if ([vc isKindOfClass:NSClassFromString(@"SendTransactionViewController")]) {
            [arrVcs removeObject:vc];
            self.navigationController.viewControllers = arrVcs;
            break;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    if (self.isFromSendTxVc) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

//- (void)viewWillDisappear:(BOOL)animated{
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
//}

- (void)configView{
    self.title = [LanguageService contentForKey:@"txDetailTitle"];
    ViewRadius(self.btnSignature, 4.0f);
    ViewBorderRadius(self.btnCancelTx, 4.0, 1.0, [UIColor colorWithHexString:@"#FF3333"]);
    if (self.isFromSendTxVc) {
        self.isShowLeftBack = NO;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:[LanguageService contentForKey:@"done"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"#FF9502"] forState:UIControlStateNormal];
        btn.frame = CGRectMake(0, 0, 40, 40);
        [btn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = rightButtonItem;
    }
    self.constraintViewStatusWidth.constant = ScreenWidth;
    [self configDataFromServerTransaction];
    [self configDataFromVcashTxLog];
    
    self.labelTxStatus.text = txStatus;
    self.imageViewTxStatus.image = imageTxStatus;
    self.labelTxid.text = tx_id;
    self.labelSender.text = sender_id;
    self.labelRecipient.text = receiver_id;
    NSString *amountStr = @([WalletWrapper nanoToVcash:amount]).p09fString;
    self.labelAmount.text = [NSString stringWithFormat:@"%@ VCash", amountStr];
    self.labelFee.text = [NSString stringWithFormat:@"%@ VCash", @([WalletWrapper nanoToVcash:fee]).p09fString];
    self.labelTxTime.text = create_time > 0 ? [[NSDate dateWithTimeIntervalSince1970:create_time] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"] : [[NSDate date] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

- (void)configDataFromServerTransaction{
    if (!self.serverTx) {
        return;
    }
    imageTxStatus = [UIImage imageNamed:@"ongoingdetail.png"];
    self.btnSignature.localTitle = self.serverTx.isSend ? @"verifySign" :  @"reveiveSign";
    self.btnCancelTx.hidden = !self.serverTx.isSend;
    switch (self.serverTx.status) {
        case TxDefaultStatus:{
            //default status
            txStatus = self.serverTx.isSend ? [LanguageService contentForKey:@"waitingSenderSign"] : [LanguageService contentForKey:@"waitingRecipientSign"];
            self.btnSignature.hidden = NO;
        }
            break;
        case TxFinalized:{
            txStatus = [LanguageService contentForKey:@"waitingConfirming"];
            self.btnSignature.hidden = YES;
            self.btnCancelTx.hidden = YES;
        }
            break;
            
        case TxReceiverd:{
            //The recipient has already signed, waiting for the sender to broadcast
            txStatus = self.serverTx.isSend ? [LanguageService contentForKey:@"waitingSenderSign"] : [LanguageService contentForKey:@"waitingRecipientSign"];
        }
            break;
            
        case TxCanceled:{
            imageTxStatus = [UIImage imageNamed:@"canceldetail.png"];
            txStatus = [LanguageService contentForKey:@"transactionCanceled"];
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

- (void)configDataFromVcashTxLog{
    if (!self.txLog) {
        return;
    }
    switch (self.txLog.confirm_state) {
        case DefaultState:{
            if (self.txLog.tx_type == TxSent) {
                imageTxStatus = [UIImage imageNamed:@"ongoingdetail.png"];
                txStatus = [LanguageService contentForKey:@"waitingRecipientSign"];
                self.btnSignature.localTitle =  @"verifySign";
                self.btnCancelTx.hidden = NO;
                if (self.txLog.status == TxDefaultStatus) {
                    self.btnSignature.hidden = YES;
                }else if(self.txLog.status == TxReceiverd){
                    if (!self.serverTx) {
                        self.serverTx = [[ServerTxManager shareInstance] getServerTxByTx_id:self.txLog.tx_slate_id];
                    }
                    self.btnSignature.hidden = !self.serverTx;
                }
            }else if (self.txLog.tx_type == TxReceived){
                //The recipient has already signed
                imageTxStatus = [UIImage imageNamed:@"ongoingdetail.png"];
                txStatus = [LanguageService contentForKey:@"waitingSenderSign"];
                self.btnSignature.hidden = YES;
                self.btnCancelTx.hidden = YES;
                
            }
        }
            break;
        case LoalConfirmed:{
            //tx has benn post, but not confirm by node
            txStatus = [LanguageService contentForKey:@"waitingConfirming"];
            imageTxStatus = [UIImage imageNamed:@"ongoingdetail.png"];
            self.btnSignature.hidden = YES;
            self.btnCancelTx.hidden = YES;
        }
            
            break;
        case NetConfirmed:{
            //confirm by node
            txStatus = [LanguageService contentForKey:@"transactionCompleted"];
            imageTxStatus = [UIImage imageNamed:@"confirmdetail.png"];
            self.btnSignature.hidden = YES;
            self.btnCancelTx.hidden = YES;
            
        }
            break;
            
        default:
            break;
    }
    tx_id = (self.txLog.tx_slate_id ? self.txLog.tx_slate_id :  [LanguageService contentForKey:@"unreachable"]);
    [self configInfoFromTx_type:self.txLog.tx_type];
    fee = self.txLog.fee;
    create_time = self.txLog.create_time;
}

- (void)configInfoFromTx_type:(TxLogEntryType)tx_type{
    switch (tx_type) {
        case ConfirmedCoinbase:{
            tx_id = [LanguageService contentForKey:@"coinbase"];
            sender_id = [LanguageService contentForKey:@"coinbase"];
            receiver_id =  [VcashWallet shareInstance].userId;
            amount = llabs((int64_t)self.txLog.amount_credited - (int64_t)self.txLog.amount_debited);
        }
            break;
            
        case TxSent:{
            sender_id =  [VcashWallet shareInstance].userId;
            receiver_id = self.txLog.parter_id ? self.txLog.parter_id : [LanguageService contentForKey:@"unreachable"];
            amount = llabs((int64_t)self.txLog.amount_credited - (int64_t)self.txLog.amount_debited) - (int64_t)self.txLog.fee;
        }
            break;
            
        case TxReceived:{
            sender_id = self.txLog.parter_id ? self.txLog.parter_id : [LanguageService contentForKey:@"unreachable"];
            receiver_id = [VcashWallet shareInstance].userId;
            amount = llabs((int64_t)self.txLog.amount_credited - (int64_t)self.txLog.amount_debited);
        }
            break;
            
        case TxReceivedCancelled:{
            imageTxStatus = [UIImage imageNamed:@"canceldetail.png"];
            txStatus = [LanguageService contentForKey:@"transactionCanceled"];
            self.btnSignature.hidden = YES;
            self.btnCancelTx.hidden = NO;
            [self.btnCancelTx setTitle:[LanguageService contentForKey:@"deleteTransaction"] forState:UIControlStateNormal];
            [self.btnCancelTx setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
            sender_id =  self.txLog.parter_id ? self.txLog.parter_id : [LanguageService contentForKey:@"unreachable"];
            receiver_id = [VcashWallet shareInstance].userId;
            amount = llabs((int64_t)self.txLog.amount_credited - (int64_t)self.txLog.amount_debited);
        }
            break;
            
        case TxSentCancelled:{
            imageTxStatus = [UIImage imageNamed:@"canceldetail.png"];
            txStatus = [LanguageService contentForKey:@"transactionCanceled"];
            self.btnSignature.hidden = YES;
            self.btnCancelTx.hidden = NO;
            [self.btnCancelTx setTitle:[LanguageService contentForKey:@"deleteTransaction"] forState:UIControlStateNormal];
            [self.btnCancelTx setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
            sender_id =  [VcashWallet shareInstance].userId;
            receiver_id = self.txLog.parter_id ? self.txLog.parter_id : [LanguageService contentForKey:@"unreachable"];
            amount = llabs((int64_t)self.txLog.amount_credited - (int64_t)self.txLog.amount_debited) - (int64_t)self.txLog.fee;
        }
            break;
        default:
            break;
    }
}

- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)clickedBtnSignature:(id)sender {
    [MBHudHelper startWorkProcessWithTextTips:@""];
    BOOL isSend = NO;
    if (self.serverTx) {
        isSend = self.serverTx.isSend;
    }
    if (self.txLog) {
        isSend = (self.txLog.tx_type == TxSent);
    }
    
    
    if (isSend){
        [WalletWrapper finalizeTransaction:self.serverTx withComplete:^(BOOL yesOrNo, id _Nullable data){
            NSString *tip = yesOrNo ? [LanguageService contentForKey:@"successfulBroadcast"] : [LanguageService contentForKey:@"broadcastFailure"];
            [MBHudHelper endWorkProcessWithSuc:yesOrNo andTextTips:tip];
            if (yesOrNo) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
    else{
        [WalletWrapper receiveTransaction:self.serverTx withComplete:^(BOOL yesOrNo, id _Nullable data) {
            NSString *tip = yesOrNo ? [LanguageService contentForKey:@"successfulSignature"] : [LanguageService contentForKey:@"signatureFailed"];
            [MBHudHelper endWorkProcessWithSuc:yesOrNo andTextTips:tip];
            if (yesOrNo) {
                 [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
    
    
}


- (IBAction)clickedBtnCancelTx:(id)sender {
    
    if (self.txLog) {
            switch (self.txLog.tx_type) {
                case TxSent:{
                    //sent
                    if (self.txLog.confirm_state == DefaultState) {
                          [self cancleTxWith:self.txLog];
                    }
                }
                    break;
                case TxSentCancelled:
                case TxReceivedCancelled:{
                    //delete transaction
                    [self deleteTransactionWith:self.txLog];
                }
                    break;
                    
                default:
                    break;
            }
    }
    
    if(self.serverTx){
        if (self.serverTx.status == TxReceived) {
            VcashTxLog *txLog =  [WalletWrapper getTxByTxid:self.serverTx.tx_id];
            [self cancleTxWith:txLog];
        }
    }
    
   
}

- (void)deleteTransactionWith:(VcashTxLog *)txlog{
    BOOL ret = [[VcashDataManager shareInstance] deleteTxBySlateId:txlog.tx_slate_id];
    if (!ret) {
        [MBHudHelper showTextTips:[LanguageService contentForKey:@"deleteFailed"] onView:nil withDuration:1.0];
        return;
    }
    [MBHudHelper showTextTips:[LanguageService contentForKey:@"deleteSuc"] onView:nil withDuration:1.0];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)cancleTxWith:(VcashTxLog *)txlog{
    if ([WalletWrapper cancelTransaction:txlog]){
        [MBHudHelper showTextTips:@"Tx cancel suc" onView:nil withDuration:1];
        [self.navigationController popViewControllerAnimated:YES];
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
