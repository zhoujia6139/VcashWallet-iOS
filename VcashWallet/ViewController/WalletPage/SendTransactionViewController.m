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
#import "TransactionDetailViewController.h"
#import "TransactionDetailView.h"
#import "AddressBookViewController.h"


#define CGrayColor [UIColor colorWithHexString:@"#EEEEEE"]

#define COrangeColor  [UIColor colorWithHexString:@"#FF9502"]

@interface SendTransactionViewController ()<UITextFieldDelegate,UITextViewDelegate,ScanViewControllerDelegate,AddressBookViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UIView *promptView;

@property (weak, nonatomic) IBOutlet UITextView *targetAddressTextView;

@property (weak, nonatomic) IBOutlet VcashLabel *labelPlaceHolder;

@property (weak, nonatomic) IBOutlet UITextField *amountField;

@property (weak, nonatomic) IBOutlet UIView *viewLineSendto;

@property (weak, nonatomic) IBOutlet UIView *viewLineAmount;

@property (weak, nonatomic) IBOutlet VcashLabel *labelAvailable;

@property (weak, nonatomic) IBOutlet VcashButton *sendBtn;

@property (weak, nonatomic) IBOutlet VcashLabel *unit;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextViewHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintContentViewWidth;

@property (weak, nonatomic) IBOutlet UITextField *receiverAddress;

@end

@implementation SendTransactionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.tokenType) {
        VcashTokenInfo* info = [WalletWrapper getTokenInfo:self.tokenType];
        self.navigationItem.title = [NSString stringWithFormat:@"Send %@", info.Name];
        if (info.Name.length <=5) {
            self.unit.text = info.Name;
        } else {
            self.unit.text = nil;
        }
    } else {
        self.navigationItem.title = [LanguageService contentForKey:@"sendVcash"];
        self.unit.text = @"VCash";
    }
    
    ViewRadius(self.promptView, 4.0);
    self.targetAddressTextView.scrollEnabled  = NO;
    self.targetAddressTextView.contentInset = UIEdgeInsetsMake(0, 0, 3, 0);
    self.targetAddressTextView.textContainerInset = UIEdgeInsetsMake(10, 0, 0, 0);
    self.constraintContentViewWidth.constant = ScreenWidth - 20 - 85;
    self.targetAddressTextView.delegate = self;
    [self setTextViewHeight];
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:[LanguageService contentForKey:@"enterAmount"]];
    [placeholder addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, placeholder.length)];
    [placeholder addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, placeholder.length)];
    self.amountField.font = [UIFont robotoRegularWithSize:22.0f];
    self.amountField.attributedPlaceholder = placeholder;
    [self.amountField addTarget:self action:@selector(enterAmount:) forControlEvents:UIControlEventEditingChanged];
    self.sendBtn.backgroundColor = COrangeEnableColor;
    self.sendBtn.userInteractionEnabled = NO;
    ViewRadius(self.sendBtn, 4.0);
    WalletBalanceInfo* info;
    if (self.tokenType){
        info = [WalletWrapper getWalletTokenBalanceInfo:self.tokenType];
    } else {
        info = [WalletWrapper getWalletBalanceInfo];
    }
    NSMutableAttributedString *availableAttribute = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ",[LanguageService contentForKey:@"available"]] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    NSAttributedString *spendableAttribute = [[NSAttributedString alloc] initWithString:@([WalletWrapper nanoToVcash:info.spendable]).p09fString attributes:@{NSFontAttributeName:[UIFont robotoRegularWithSize:12]}];
    [availableAttribute appendAttributedString:spendableAttribute];
    self.labelAvailable.textColor = COrangeColor;
    self.labelAvailable.attributedText = availableAttribute;
//    self.labelAvailable.text = [NSString stringWithFormat:@"%@: %@ V",[LanguageService contentForKey:@"available"],@([WalletWrapper nanoToVcash:info.spendable]).p09fString];
}


- (void)setTextViewHeight{
    CGSize size = [self.targetAddressTextView sizeThatFits:CGSizeMake(ScreenWidth - 105, 1000)];
    CGFloat textViewHeight = size.height + 5;
    if (textViewHeight > 30) {
        self.constraintTextViewHeight.constant = textViewHeight;
    }else{
        textViewHeight = 30;
        self.constraintTextViewHeight.constant = 30;
    }
    self.targetAddressTextView.contentSize = CGSizeMake(ScreenWidth - 105, textViewHeight);
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

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    self.viewLineSendto.backgroundColor = COrangeColor;
    [self setTextViewHeight];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
     self.viewLineSendto.backgroundColor = CGrayColor;
}

- (void)textViewDidChange:(UITextView *)textView{
    self.labelPlaceHolder.hidden = textView.text.length > 0 ? YES : NO;
    [self setTextViewHeight];
    if (self.amountField.text.length > 0 && self.targetAddressTextView.text.length > 0) {
        self.sendBtn.backgroundColor = COrangeColor;
        self.sendBtn.userInteractionEnabled = YES;
    }else{
        self.sendBtn.backgroundColor = COrangeEnableColor;
        self.sendBtn.userInteractionEnabled = NO;
    }
}


#pragma mark - ScanViewControllerDelegate

- (void)scanWithResult:(NSString *)result{
    self.targetAddressTextView.text = result ? result : @"";
    self.labelPlaceHolder.hidden = result ? YES : NO;
    [self setTextViewHeight];
    if (self.amountField.text.length > 0 && self.targetAddressTextView.text.length > 0) {
        self.sendBtn.backgroundColor = COrangeColor;
        self.sendBtn.userInteractionEnabled = YES;
    }else{
        self.sendBtn.backgroundColor = COrangeEnableColor;
        self.sendBtn.userInteractionEnabled = NO;
    }
}

#pragma mark - AddressBookViewControllerDelegate
- (void)selectedAddressBook:(AddressBookModel *)model{
    self.targetAddressTextView.text = model.address;
    self.labelPlaceHolder.hidden = model.address.length > 0 ? YES : NO;
    [self setTextViewHeight];
    if (self.amountField.text.length > 0 && self.targetAddressTextView.text.length > 0) {
        self.sendBtn.backgroundColor = COrangeColor;
        self.sendBtn.userInteractionEnabled = YES;
    }else{
        self.sendBtn.backgroundColor = COrangeEnableColor;
        self.sendBtn.userInteractionEnabled = NO;
    }
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
    
    if (![self isUrlAddress:self.targetAddressTextView.text]) {
        if (self.targetAddressTextView.text.length != 66) {
            [self.view makeToast:[LanguageService contentForKey:@"addressFormatIncorrect"]];
            return;
        }
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
        [WalletWrapper createSendTransaction:self.tokenType andAmount:[WalletWrapper vcashToNano:amount] andProofAddress:self.receiverAddress.text withComplete:^(BOOL yesOrNo, id retData) {
            if (yesOrNo){
                VcashSlate* slate = (VcashSlate*)retData;
                TransactionDetailView *txDetailView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TransactionDetailView class]) owner:nil options:nil] firstObject];
                txDetailView.senderAddress = self.targetAddressTextView.text;
                txDetailView.btnTitle = [LanguageService contentForKey:@"ok"];
                txDetailView.slate = slate;
                __weak typeof(self) weakSelf  = self;
                txDetailView.signCallBack = ^(VcashSlate * _Nonnull slate) {
                    __strong typeof(weakSelf) strongSelf  = weakSelf;
                    if ([strongSelf isUrlAddress:strongSelf.targetAddressTextView.text]) {
                        [strongSelf sendTransactionWithUrl:strongSelf.targetAddressTextView.text slate:slate];
                    }else{
                        [strongSelf sendTransactionWithUseId:strongSelf.targetAddressTextView.text slate:slate];
                    }
                    [strongSelf.navigationController popViewControllerAnimated:YES];
                };
                [txDetailView show];
            }
            else{
//                [MBHudHelper showTextTips:[NSString stringWithFormat:@"%@", retData] onView:nil withDuration:1.5];
                UIAlertController *alterVc = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@", retData] message:@"" preferredStyle:UIAlertControllerStyleAlert];
                [alterVc addAction:[UIAlertAction actionWithTitle:[LanguageService contentForKey:@"ok"] style:UIAlertActionStyleDefault handler:nil]];
                [self.navigationController presentViewController:alterVc animated:YES completion:nil];
            }
            
        }];

    }
}

- (IBAction)clickedBtnAddressBook:(id)sender {
    AddressBookViewController *addressBookVc = [[AddressBookViewController alloc] init];
    addressBookVc.fromSendTxVc = YES;
    addressBookVc.delegate = self;
    [self.navigationController pushViewController:addressBookVc animated:YES];
}


- (BOOL)isUrlAddress:(NSString*)url{
    if ([url hasPrefix:@"http"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isNumber:(NSString *)strValue{
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
     [MBHudHelper startWorkProcessWithTextTips:[LanguageService contentForKey:@"sending"]];
    [WalletWrapper sendTransaction:slate forUser:useId withComplete:^(BOOL yesOrNo, id _Nullable data) {
        if (yesOrNo){
             [MBHudHelper endWorkProcessWithSuc:yesOrNo andTextTips:[LanguageService contentForKey:@"sendSuc"]];
             VcashTxLog *txLog =  [[VcashDataManager shareInstance] getTxBySlateId:slate.uuid];
            [self pushTranscactionDetailVcWith:txLog];
        }else{
             [MBHudHelper endWorkProcessWithSuc:yesOrNo andTextTips:[LanguageService contentForKey:@"sendFailed"]];
        }
    }];
}

- (void)sendTransactionWithUrl:(NSString *)url slate:(VcashSlate *)slate{
    [MBHudHelper startWorkProcessWithTextTips:[LanguageService contentForKey:@"sending"]];
    [WalletWrapper sendTransaction:slate forUrl:url withComplete:^(BOOL yesOrNo, id _Nullable data) {
        if (yesOrNo) {
            [MBHudHelper endWorkProcessWithSuc:yesOrNo andTextTips:[LanguageService contentForKey:@"sendSuc"]];
//            VcashTxLog *txLog =  [[VcashDataManager shareInstance] getTxBySlateId:slate.uuid];
//            txLog.confirm_state = LoalConfirmed;
//            [self pushTranscactionDetailVcWith:txLog];
        }else{
            [MBHudHelper endWorkProcessWithSuc:yesOrNo andTextTips:[LanguageService contentForKey:@"sendFailed"]];
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
