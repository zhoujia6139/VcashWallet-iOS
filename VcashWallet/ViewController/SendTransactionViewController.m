//
//  SendTransactionViewController.m
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/3.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "SendTransactionViewController.h"
#import "WalletWrapper.h"
#import "SendTransactionConfirmView.h"
#import "ScanViewController.h"
#import "TransactionDetailViewController/TransactionDetailViewController.h"


#define CGrayColor [UIColor colorWithHexString:@"#EEEEEE"]

#define COrangeColor  [UIColor colorWithHexString:@"#FF9502"]

@interface SendTransactionViewController ()<UITextFieldDelegate,ScanViewControllerDelegate>



@property (weak, nonatomic) IBOutlet UITextField *targetAddressField;

@property (weak, nonatomic) IBOutlet UITextField *amountField;

@property (weak, nonatomic) IBOutlet UIView *viewLineSendto;

@property (weak, nonatomic) IBOutlet UIView *viewLineAmount;


@property (weak, nonatomic) IBOutlet VcashButton *sendBtn;



@end

@implementation SendTransactionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [LanguageService contentForKey:@"sendVcash"];
    [self.amountField addTarget:self action:@selector(enterAmount:) forControlEvents:UIControlEventEditingChanged];
    self.sendBtn.backgroundColor = COrangeEnableColor;
    self.sendBtn.userInteractionEnabled = NO;
    ViewRadius(self.sendBtn, 4.0);
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.targetAddressField) {
        self.viewLineSendto.backgroundColor = COrangeColor;
    }
    if (textField == self.amountField) {
        self.viewLineAmount.backgroundColor = COrangeColor;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.targetAddressField) {
        self.viewLineSendto.backgroundColor = CGrayColor;
    }
    if (textField == self.amountField) {
        self.viewLineAmount.backgroundColor = CGrayColor;
    }
}

#pragma mark - ScanViewControllerDelegate

- (void)scanWithResult:(NSString *)result{
    self.targetAddressField.text = result ? result : @"";
}


- (void)enterAmount:(UITextField *)textField{
    NSRange ran = [textField.text rangeOfString:@"."];
    if (ran.location != NSNotFound) {
        if (textField.text.length -  ran.location - 1 > 9) {
            textField.text = [textField.text substringWithRange:NSMakeRange(0, textField.text.length - ran.location)];
        }
    }
    if (textField.text.length > 0 && self.targetAddressField.text.length > 0) {
        self.sendBtn.backgroundColor = COrangeColor;
        self.sendBtn.userInteractionEnabled = YES;
    }else{
        self.sendBtn.backgroundColor = COrangeEnableColor;
        self.sendBtn.userInteractionEnabled = NO;
    }
}

- (IBAction)clickSend:(id)sender {
    NSString* strAmount = self.amountField.text;
    NSNumber* numberAmount = [NSNumber numberWithString:strAmount];
    double amount = [numberAmount doubleValue];
    if (self.targetAddressField.text && amount > 0)
    {
        [WalletWrapper createSendTransaction:self.targetAddressField.text amount:[WalletWrapper vcashToNano:amount] fee:0 withComplete:^(BOOL yesOrNo, id retData) {
            if (yesOrNo){
                VcashSlate* slate = (VcashSlate*)retData;
                [self sendTransactionWithUseId:self.targetAddressField.text slate:slate];
            }
            else{
                [MBHudHelper showTextTips:[NSString stringWithFormat:@"SendFailed:%@", retData] onView:nil withDuration:1.5];
            }
            
        }];

    }
}

- (void)sendTransactionWithUseId:(NSString *)useId slate:(VcashSlate *)slate{
    [WalletWrapper sendTransaction:slate forUser:useId withComplete:^(BOOL yesOrNo, id _Nullable data) {
        if (yesOrNo){
            [MBHudHelper showTextTips:@"Send success!" onView:nil withDuration:1];
             VcashTxLog *txLog =  [[VcashDataManager shareInstance] getTxBySlateId:slate.uuid];
            [self pushTranscactionDetailVcWith:txLog];
        }
        else{
            [MBHudHelper showTextTips:[NSString stringWithFormat:@"Send failed:%@", data] onView:nil withDuration:1];
        }
    }];
}

- (void)pushTranscactionDetailVcWith:(VcashTxLog *)txLog{
    TransactionDetailViewController *transactionDetailVc = [[TransactionDetailViewController alloc] init];
    transactionDetailVc.isFromSendTxVc = YES;
    transactionDetailVc.txLog = txLog;
    [self.navigationController pushViewController:transactionDetailVc animated:YES];
}

- (IBAction)pushScanQRVc:(id)sender {
    ScanViewController *scanVc = [[ScanViewController alloc] init];
    scanVc.delegate = self;
    [self.navigationController pushViewController:scanVc animated:YES];
}


//- (IBAction)clickContract:(id)sender {
//    [self.navigationController pushViewController:[MyContractViewController new] animated:YES];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
