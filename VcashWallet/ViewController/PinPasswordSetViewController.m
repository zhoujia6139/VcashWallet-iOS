//
//  PinPasswordSetViewController.m
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/16.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "PinPasswordSetViewController.h"
#import "PinPasswordInputView.h"
#import "AlertView.h"

#define CGrayColor [UIColor colorWithHexString:@"#EEEEEE"]
#define COrangeColor  [UIColor colorWithHexString:@"#FF9502"]
#define CRedColor [UIColor colorWithHexString:@"#FF3333"]

@interface PinPasswordSetViewController ()<UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet VcashLabel *promptLabel;


@property (nonatomic, strong) PinPasswordInputView *pasView;

@property (weak, nonatomic) IBOutlet VcashTextField *passwordTextField;


@property (weak, nonatomic) IBOutlet VcashTextField *confirmPasTextField;

@property (weak, nonatomic) IBOutlet VcashButton *startUseWalletBtn;

@property (weak, nonatomic) IBOutlet UIView *pasLineView;


@property (weak, nonatomic) IBOutlet UIView *confirmPasLineView;

@property (weak, nonatomic) IBOutlet VcashLabel *passwordNotmatchLabel;


@end

@implementation PinPasswordSetViewController
{
    NSString* firstPass;
    NSString* secondPass;
    BOOL isNotmatch;
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    if (!self.isRecover) {
        NSMutableArray *vcs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        NSInteger count = vcs.count;
        for (NSInteger i = count - 1; i >= 0; i--) {
            UIViewController *vc = vcs[i];
            if ([vc isKindOfClass:NSClassFromString(@"ConfirmSeedphraseViewController")]) {
                [vcs removeObject:vc];
                break;
            }
        }
        self.navigationController.viewControllers = vcs;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.passwordTextField becomeFirstResponder];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)backBtnClicked{
    if (!self.isRecover) {
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
        AlertView *alertView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([AlertView class]) owner:nil options:nil] firstObject];
        alertView.title = [LanguageService contentForKey:@"returnTitle"];
        alertView.msg = [LanguageService contentForKey:@"retunrnMsg"];
        alertView.doneTitle = [LanguageService contentForKey:@"doneTitle"];
        __weak typeof(self) weakSelf = self;
        alertView.doneCallBack = ^{
            __weak typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.navigationController popViewControllerAnimated:YES];
        };
        [alertView show];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.passwordTextField) {
        self.pasLineView.backgroundColor = COrangeColor;
    }
    if (textField == self.confirmPasTextField) {
        self.confirmPasLineView.backgroundColor = isNotmatch  ? CRedColor :COrangeColor;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.passwordTextField) {
        self.pasLineView.backgroundColor = CGrayColor;
    }
    if (textField == self.confirmPasTextField) {
        self.confirmPasLineView.backgroundColor = isNotmatch ? CRedColor : CGrayColor;
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
        self.passwordNotmatchLabel.hidden = NO;
        self.confirmPasLineView.backgroundColor = [UIColor colorWithHexString:@"#FF3333"];
        isNotmatch = YES;
        return;
    }
    self.passwordNotmatchLabel.hidden = YES;
    self.confirmPasLineView.backgroundColor = [self.confirmPasTextField isFirstResponder] ?  COrangeColor : CGrayColor;
    NSString *password = self.passwordTextField.text;
    
    if (self.isChangePassword) {
        NSString *wordStr  = [[UserCenter sharedInstance] getStoredMnemonicWordsWithKey:self.currentPassword];
        [[UserCenter sharedInstance] storeMnemonicWords:wordStr withKey:password];
        [MBHudHelper showTextTips:[LanguageService contentForKey:@"changePasswordSuc"] onView:nil withDuration:1.5];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    
    [WalletWrapper clearWallet];
    NSString* wordStr = [self.mnemonicWordsArr componentsJoinedByString:@" "];
    [[UserCenter sharedInstance] storeMnemonicWords:wordStr withKey:password];
    if (self.isRecover) {
        [MBHudHelper startWorkProcessWithTextTips:[LanguageService contentForKey:@"recovering"]];
        [[UserCenter sharedInstance] writeRecoverStatusWithFailed:YES];
        [WalletWrapper checkWalletUtxoWithComplete:^(BOOL yesOrNo, id ret) {
            if (yesOrNo) {
                [[UserCenter sharedInstance] writeRecoverStatusWithFailed:NO];
                 [NavigationCenter showWalletPage:self.isRecover createNewWallet:NO];
            }else{
                 [MBHudHelper endWorkProcessWithSuc:yesOrNo andTextTips:[LanguageService contentForKey:@"recoveryFailure"]];
            }
            
        }];
        return;
    }
    [[UserCenter sharedInstance] writeRecoverStatusWithFailed:NO];
    [NavigationCenter showWalletPage:self.isRecover createNewWallet:YES];
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
