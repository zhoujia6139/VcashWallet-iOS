//
//  AddAddressBookViewController.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/7/12.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "AddAddressBookViewController.h"
#import "AddressBookModel.h"
#import "AddressBookManager.h"
#import "ScanViewController.h"

@interface AddAddressBookViewController ()<ScanViewControllerDelegate,UITextFieldDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textFieldRemarkName;

@property (weak, nonatomic) IBOutlet UIView *viewLineRemark;


@property (weak, nonatomic) IBOutlet UITextView *textViewUserIDOrHttpAddress;

@property (weak, nonatomic) IBOutlet UIView *viewLineUserIdOrHttpAddress;

@property (weak, nonatomic) IBOutlet VcashLabel *labelPlaceHolder;

@property (weak, nonatomic) IBOutlet UIButton *btnSave;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextViewHeight;

@end

@implementation AddAddressBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = [LanguageService contentForKey:@"addAddressTitle"];
    self.textFieldRemarkName.delegate = self;
    if (self.remarkName && self.remarkName.length > 0) {
        self.textFieldRemarkName.text = self.remarkName;
    }
    [self.textFieldRemarkName addTarget:self action:@selector(enterRemarkName:) forControlEvents:UIControlEventEditingChanged];
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:[LanguageService contentForKey:@"enterRemarkName"]];
    [placeholder addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, placeholder.length)];
    [placeholder addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, placeholder.length)];
    self.textFieldRemarkName.attributedPlaceholder = placeholder;
    self.textViewUserIDOrHttpAddress.delegate = self;
    self.textViewUserIDOrHttpAddress.editable = !self.edit;
    self.textViewUserIDOrHttpAddress.contentInset = UIEdgeInsetsZero;
    self.textViewUserIDOrHttpAddress.scrollEnabled  = NO;
    self.textViewUserIDOrHttpAddress.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.textViewUserIDOrHttpAddress.textContainerInset = UIEdgeInsetsMake(7, 0, 0, 0);
    if (self.address && self.address.length > 0) {
        self.labelPlaceHolder.hidden = YES;
        self.textViewUserIDOrHttpAddress.text = self.address;
        [self setTextViewHeight];
    }
    if (self.remarkName.length > 0 && self.address.length > 0) {
        self.btnSave.backgroundColor = COrangeColor;
        self.btnSave.userInteractionEnabled = YES;
    }else{
        self.btnSave.backgroundColor = COrangeEnableColor;
        self.btnSave.userInteractionEnabled = NO;
    }
    ViewRadius(self.btnSave, 4.0);
}


#pragma mark - ScanViewControllerDelegate
- (void)scanWithResult:(NSString *)result{
    self.textViewUserIDOrHttpAddress.text = result;
    [self setTextViewHeight];
    self.labelPlaceHolder.hidden = result.length > 0 ? YES : NO;
    if (self.textFieldRemarkName.text.length > 0 && self.textViewUserIDOrHttpAddress.text.length > 0) {
        self.btnSave.backgroundColor = COrangeColor;
        self.btnSave.userInteractionEnabled = YES;
    }else{
        self.btnSave.backgroundColor = COrangeEnableColor;
        self.btnSave.userInteractionEnabled = NO;
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.viewLineRemark.backgroundColor = COrangeColor;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.viewLineRemark.backgroundColor = CGrayColor;
}


#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    self.viewLineUserIdOrHttpAddress.backgroundColor = COrangeColor;
    [self setTextViewHeight];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    self.viewLineUserIdOrHttpAddress.backgroundColor = CGrayColor;
}

- (void)textViewDidChange:(UITextView *)textView{
    self.labelPlaceHolder.hidden = textView.text.length > 0 ? YES : NO;
    [self setTextViewHeight];
    if (self.textFieldRemarkName.text.length > 0 && self.textViewUserIDOrHttpAddress.text.length > 0) {
        self.btnSave.backgroundColor = COrangeColor;
        self.btnSave.userInteractionEnabled = YES;
    }else{
        self.btnSave.backgroundColor = COrangeEnableColor;
        self.btnSave.userInteractionEnabled = NO;
    }
}

- (void)enterRemarkName:(UITextField *)textField{
    if (self.textFieldRemarkName.text.length > 0 && self.textViewUserIDOrHttpAddress.text.length > 0) {
        self.btnSave.backgroundColor = COrangeColor;
        self.btnSave.userInteractionEnabled = YES;
    }else{
        self.btnSave.backgroundColor = COrangeEnableColor;
        self.btnSave.userInteractionEnabled = NO;
    }
}

- (void)setTextViewHeight{
    CGSize size = [self.textViewUserIDOrHttpAddress sizeThatFits:CGSizeMake(ScreenWidth - 105, 1000)];
    CGFloat textViewHeight = size.height + 7;
    if (textViewHeight > 30) {
        self.constraintTextViewHeight.constant = textViewHeight;
    }else{
        textViewHeight = 30;
        self.constraintTextViewHeight.constant = 30;
    }
    self.textViewUserIDOrHttpAddress.contentSize = CGSizeMake(ScreenWidth - 105, textViewHeight);
}

- (IBAction)clickedBtnScanQR:(id)sender {
    ScanViewController *scanVc = [[ScanViewController alloc] init];
    scanVc.delegate = self;
    [self.navigationController pushViewController:scanVc animated:YES];
}


- (IBAction)clickedSaveAddress:(id)sender {
    if (self.textFieldRemarkName.text.length == 0) {
        [self.view makeToast:[LanguageService contentForKey:@"remarkNotbeEmpty"]];
        return;
    }
    
    if (self.textViewUserIDOrHttpAddress.text.length == 0) {
        [self.view makeToast:[LanguageService contentForKey:@"addressNotbeEmpty"]];
        return;
    }
    
    AddressBookModel *model = [AddressBookModel new];
    model.remarkName = self.textFieldRemarkName.text;
    model.address = self.textViewUserIDOrHttpAddress.text;
    if ([[AddressBookManager shareInstance] isExistByAddressBookModel:model] && !self.edit) {
        [AppHelper resignFirstResonder];
        [MBHudHelper showTextTips:[LanguageService contentForKey:@"addressAlreadyExist"] onView:nil withDuration:1.0];
        return;
    }
    BOOL success =  [[AddressBookManager shareInstance] writeAddressBookModel:model];
    if (success) {
        [MBHudHelper showTextTips:self.edit ? [LanguageService contentForKey:@"editSuc"] : [LanguageService contentForKey:@"addSuc"] onView:nil withDuration:1.0];
        if (self.delegate && [self.delegate respondsToSelector:@selector(saveSucWithAddressBookModel:)]) {
            [self.delegate saveSucWithAddressBookModel:model];
        }
        [self.navigationController popViewControllerAnimated:YES];
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
