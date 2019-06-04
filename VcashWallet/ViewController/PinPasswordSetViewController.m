//
//  PinPasswordSetViewController.m
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/16.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "PinPasswordSetViewController.h"
#import "PinPasswordInputView.h"

#define CGrayColor [UIColor colorWithHexString:@"#EEEEEE"]
#define COrangeColor  [UIColor colorWithHexString:@"#FF9502"]

@interface PinPasswordSetViewController ()<UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet VcashLabel *promptLabel;


@property (nonatomic, strong) PinPasswordInputView *pasView;

@property (weak, nonatomic) IBOutlet VcashTextField *passwordTextField;


@property (weak, nonatomic) IBOutlet VcashTextField *confirmPasTextField;

@property (weak, nonatomic) IBOutlet VcashButton *startUseWalletBtn;

@property (weak, nonatomic) IBOutlet UIView *pasLineView;


@property (weak, nonatomic) IBOutlet UIView *confirmPasLineView;

@end

@implementation PinPasswordSetViewController
{
    NSString* firstPass;
    NSString* secondPass;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [LanguageService contentForKey:@"passwordTitle"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.startUseWalletBtn.backgroundColor = CGrayColor;
    ViewRadius(self.startUseWalletBtn, 4.0);
    
    if (self.isChangePassword) {
        self.promptLabel.localText = @"createNewPass";
        self.startUseWalletBtn.localTitle = @"saveNewPassword";
    }
    
    [self.confirmPasTextField addTarget:self action:@selector(fillConfirmPassword:) forControlEvents:UIControlEventEditingChanged];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.passwordTextField becomeFirstResponder];
//    [self.pasView openKeyboard];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.passwordTextField) {
        self.pasLineView.backgroundColor = COrangeColor;
    }
    if (textField == self.confirmPasTextField) {
        self.confirmPasLineView.backgroundColor = COrangeColor;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.passwordTextField) {
        self.pasLineView.backgroundColor = CGrayColor;
    }
    if (textField == self.confirmPasTextField) {
        self.confirmPasLineView.backgroundColor = CGrayColor;
    }
}

- (void)fillConfirmPassword:(UITextField *)textField{
    if (textField.text.length > 0 && self.passwordTextField.text.length > 0) {
        self.startUseWalletBtn.userInteractionEnabled = YES;
        self.startUseWalletBtn.backgroundColor = COrangeColor;
    }else{
        self.startUseWalletBtn.userInteractionEnabled = NO;
        self.startUseWalletBtn.backgroundColor = CGrayColor;
    }
}

- (BOOL)extracted {
    return [WalletWrapper createWalletWithPhrase:self.mnemonicWordsArr nickname:nil password:nil];
}

- (IBAction)clickedStartUseWallet:(id)sender {
    if (![self.passwordTextField.text isEqualToString:self.confirmPasTextField.text]) {
         [MBHudHelper showTextTips:[LanguageService contentForKey:@"twoinputsNotSame"] onView:nil withDuration:1.5];
        return;
    }
    NSString *password = self.passwordTextField.text;
    
    if (self.isChangePassword) {
        NSString *wordStr  = [[UserCenter sharedInstance] getStoredMnemonicWordsWithKey:self.currentPassword];
        [[UserCenter sharedInstance] storeMnemonicWords:wordStr withKey:password];
        [MBHudHelper showTextTips:[LanguageService contentForKey:@"changePasswordSuc"] onView:nil withDuration:1.5];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    
    BOOL yesOrNo = [self extracted];
    if (yesOrNo)
    {
        NSString* wordStr = [self.mnemonicWordsArr componentsJoinedByString:@" "];
        [[UserCenter sharedInstance] storeMnemonicWords:wordStr withKey:password];
        [NavigationCenter showWalletPage:self.isRecover];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
