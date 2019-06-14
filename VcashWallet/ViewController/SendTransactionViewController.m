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

@interface SendTransactionViewController ()<UITextFieldDelegate,YYTextViewDelegate,ScanViewControllerDelegate>



@property (weak, nonatomic) IBOutlet YYTextView *targetAddressTextView;

@property (weak, nonatomic) IBOutlet VcashLabel *labelPlaceHolder;

@property (weak, nonatomic) IBOutlet UITextField *amountField;

@property (weak, nonatomic) IBOutlet UIView *viewLineSendto;

@property (weak, nonatomic) IBOutlet UIView *viewLineAmount;


@property (weak, nonatomic) IBOutlet VcashButton *sendBtn;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextViewHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintContentViewWidth;


@end

@implementation SendTransactionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [LanguageService contentForKey:@"sendVcash"];
    self.constraintContentViewWidth.constant = ScreenWidth - 25 - 85;
    self.targetAddressTextView.textColor = [UIColor darkTextColor];
    self.targetAddressTextView.font = [UIFont systemFontOfSize:15];
    self.targetAddressTextView.placeholderTextColor = [UIColor lightGrayColor];
    self.targetAddressTextView.placeholderText = [LanguageService contentForKey:@"enterOrScan"];
    self.targetAddressTextView.delegate = self;
    [self setTextViewHeight];
    [self.amountField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.amountField addTarget:self action:@selector(enterAmount:) forControlEvents:UIControlEventEditingChanged];
    self.sendBtn.backgroundColor = COrangeEnableColor;
    self.sendBtn.userInteractionEnabled = NO;
    ViewRadius(self.sendBtn, 4.0);
}


- (void)setTextViewHeight{
    
    CGFloat textViewHeight = [self.targetAddressTextView.text boundingRectWithSize:CGSizeMake(ScreenWidth - 110, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.0]} context:nil].size.height;
    if (textViewHeight > 30) {
        self.constraintTextViewHeight.constant = textViewHeight + 10;
    }else{
        textViewHeight = 30;
        self.constraintTextViewHeight.constant = 30;
    }
    self.targetAddressTextView.contentSize = CGSizeMake(ScreenWidth - 110, textViewHeight);
    [self.targetAddressTextView scrollRangeToVisible:NSMakeRange(0, 0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.viewLineAmount.backgroundColor = COrangeColor;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.viewLineAmount.backgroundColor = CGrayColor;
}

#pragma mark - YYTextViewDelegate

- (BOOL)textViewShouldBeginEditing:(YYTextView *)textView{
    self.viewLineSendto.backgroundColor = COrangeColor;
    [self setTextViewHeight];
    return YES;
}

- (void)textViewDidEndEditing:(YYTextView *)textView{
     self.viewLineSendto.backgroundColor = CGrayColor;
}

- (void)textViewDidChange:(UITextView *)textView{
    self.labelPlaceHolder.hidden = textView.text.length > 0 ? YES : NO;
    [self setTextViewHeight];
}

#pragma mark - ScanViewControllerDelegate

- (void)scanWithResult:(NSString *)result{
    self.targetAddressTextView.text = result ? result : @"";
    self.labelPlaceHolder.hidden = result ? YES : NO;
    [self setTextViewHeight];
}


- (void)enterAmount:(UITextField *)textField{
    NSRange ran = [textField.text rangeOfString:@"."];
    if (ran.location != NSNotFound) {
        if (textField.text.length -  ran.location - 1 > 9) {
            textField.text = [textField.text substringWithRange:NSMakeRange(0, textField.text.length - ran.location)];
        }
    }
    if (textField.text.length > 0 && self.targetAddressTextView.text.length > 0) {
        self.sendBtn.backgroundColor = COrangeColor;
        self.sendBtn.userInteractionEnabled = YES;
    }else{
        self.sendBtn.backgroundColor = COrangeEnableColor;
        self.sendBtn.userInteractionEnabled = NO;
    }
}

- (IBAction)clickSend:(id)sender {
    if ([self.targetAddressTextView.text isEqualToString:[WalletWrapper getWalletUserId]]) {
        [self.view makeToast:[LanguageService contentForKey:@"sendSelfWarning"]];
        return;
    }
    
    if (self.targetAddressTextView.text.length != 66) {
        [self.view makeToast:[LanguageService contentForKey:@"addressFormatIncorrect"]];
        return;
    }
    
    NSString* strAmount = self.amountField.text;
    if (![self isNumber:strAmount]) {
        [self.view makeToast:[LanguageService contentForKey:@"enterDigit"]];
        return;
    }
    NSNumber* numberAmount = [NSNumber numberWithString:strAmount];
    double amount = [numberAmount doubleValue];
    if (amount == 0) {
        [self.view makeToast:[LanguageService contentForKey:@"amountLimit"]];
        return;
    }
    if (self.targetAddressTextView.text && amount > 0)
    {
        [WalletWrapper createSendTransaction:self.targetAddressTextView.text amount:[WalletWrapper vcashToNano:amount] fee:0 withComplete:^(BOOL yesOrNo, id retData) {
            if (yesOrNo){
                VcashSlate* slate = (VcashSlate*)retData;
                [self sendTransactionWithUseId:self.targetAddressTextView.text slate:slate];
            }
            else{
                [MBHudHelper showTextTips:[NSString stringWithFormat:@"%@", retData] onView:nil withDuration:1.5];
            }
            
        }];

    }
}


- (BOOL)isNumber:(NSString *)strValue
{
    if (strValue == nil || [strValue length] <= 0)
    {
        return NO;
    }
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    NSString *filtered = [[strValue componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    if (![strValue isEqualToString:filtered])
    {
        return NO;
    }
    return YES;
}


- (void)sendTransactionWithUseId:(NSString *)useId slate:(VcashSlate *)slate{
    [WalletWrapper sendTransaction:slate forUser:useId withComplete:^(BOOL yesOrNo, id _Nullable data) {
        if (yesOrNo){
            [MBHudHelper showTextTips:[LanguageService contentForKey:@"sendSuc"] onView:nil withDuration:1];
             VcashTxLog *txLog =  [[VcashDataManager shareInstance] getTxBySlateId:slate.uuid];
            [self pushTranscactionDetailVcWith:txLog];
        }
        else{
            [MBHudHelper showTextTips:[LanguageService contentForKey:@"sendFailed"] onView:nil withDuration:1];
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
