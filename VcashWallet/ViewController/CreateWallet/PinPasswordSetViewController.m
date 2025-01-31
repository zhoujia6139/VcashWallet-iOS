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
#import "ProgressView.h"
#import "LockScreenTimeService.h"

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

@property (nonatomic, strong) ProgressView *progressView;

@property (weak, nonatomic) IBOutlet UIButton *btnPasswordSecture;

@property (weak, nonatomic) IBOutlet UIButton *btnConfirmSecture;

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
    self.startUseWalletBtn.userInteractionEnabled = NO;
    self.startUseWalletBtn.backgroundColor = COrangeEnableColor;
    ViewRadius(self.startUseWalletBtn, 4.0);
    
    if (self.isChangePassword) {
        self.promptLabel.localText = @"createNewPass";
        self.startUseWalletBtn.localTitle = @"saveNewPassword";
    }
    self.passwordTextField.tintColor = COrangeColor;
    self.confirmPasTextField.tintColor = COrangeColor;
    
    UIView *rightViewPassword = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
    self.passwordTextField.rightView = rightViewPassword;
    self.passwordTextField.rightViewMode = UITextFieldViewModeAlways;
    
    UIView *rightViewConfirm = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
    self.confirmPasTextField.rightView = rightViewConfirm;
    self.confirmPasTextField.rightViewMode = UITextFieldViewModeAlways;
    
    [self.passwordTextField addTarget:self action:@selector(fillConfirmPassword:) forControlEvents:UIControlEventEditingChanged];
    [self.confirmPasTextField addTarget:self action:@selector(fillConfirmPassword:) forControlEvents:UIControlEventEditingChanged];
    
    [self.btnPasswordSecture setImage:[UIImage imageNamed:@"eyeblackclose.png"] forState:UIControlStateNormal];
    [self.btnPasswordSecture setImage:[UIImage imageNamed:@"eyeblackopen.png"] forState:UIControlStateSelected];
    
    [self.btnConfirmSecture setImage:[UIImage imageNamed:@"eyeblackclose.png"] forState:UIControlStateNormal];
    [self.btnConfirmSecture setImage:[UIImage imageNamed:@"eyeblackopen.png"] forState:UIControlStateSelected];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.isRecover && !self.isChangePassword) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
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
    if (!self.isRecover && !self.isChangePassword) {
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
    if (self.confirmPasTextField.text.length > 0 && self.passwordTextField.text.length > 0) {
        self.startUseWalletBtn.userInteractionEnabled = YES;
        self.startUseWalletBtn.backgroundColor = COrangeColor;
    }else{
        self.startUseWalletBtn.userInteractionEnabled = NO;
        self.startUseWalletBtn.backgroundColor = COrangeEnableColor;
    }
}

- (BOOL)extracted {
    return [WalletWrapper createWalletWithPhrase:self.mnemonicWordsArr nickname:nil password:nil];
}


- (IBAction)clickedBtnPasswordSecture:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    self.passwordTextField.secureTextEntry = !btn.selected;
}

- (IBAction)clickedBtnConfirmSecture:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    self.confirmPasTextField.secureTextEntry = !btn.selected;
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
        [self.progressView show];
        [[UserCenter sharedInstance] writeRecoverStatusWithFailed:YES];
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        [self startCheckWallteUtxoFromIndex:0];
        
        return;
    }
    [[UserCenter sharedInstance] writeRecoverStatusWithFailed:NO];
    [NavigationCenter showWalletPage:self.isRecover createNewWallet:YES];
    [[LockScreenTimeService shareInstance] addObserver];
}

-(void)startCheckWallteUtxoFromIndex:(uint64_t)startIndex {
    [WalletWrapper checkWalletUtxoFromIndex:startIndex WithComplete:^(BOOL yesOrNo, id ret) {
        if (yesOrNo && [ret isKindOfClass:[NSArray class]]) {
//            self.progressView.progress = 1;
//             [[UserCenter sharedInstance] writeRecoverStatusWithFailed:NO];
//             [NavigationCenter showWalletPage:self.isRecover createNewWallet:NO];
//             [[LockScreenTimeService shareInstance] addObserver];
//            [UIApplication sharedApplication].idleTimerDisabled = NO;
            [self startCheckWallteTokenUtxoFromIndex:0];
        }else if(yesOrNo && [ret isKindOfClass:[NSNumber class]]){
            self.progressView.progress = [ret floatValue];
        }else{
            NSNumber* last_index = (NSNumber*)ret;
            uint64_t lastIndex = [last_index unsignedLongValue];
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:@"restore failed! retry?" preferredStyle:UIAlertControllerStyleAlert];
            [alertVc addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                [MBHudHelper showTextTips:[LanguageService contentForKey:@"recoveryFailure"] onView:nil withDuration:1.5];
                [self.progressView removeFromSuperview];
                self.progressView = nil;
            }]];
            [alertVc addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self startCheckWallteUtxoFromIndex:lastIndex];
            }]];
            [self.navigationController presentViewController:alertVc animated:YES completion:nil];
        }
    }];
}

-(void)startCheckWallteTokenUtxoFromIndex:(uint64_t)startIndex {
    [WalletWrapper checkWalletTokenUtxoFromIndex:startIndex WithComplete:^(BOOL yesOrNo, id ret) {
        if (yesOrNo && [ret isKindOfClass:[NSArray class]]) {
            self.progressView.progress = 1;
             [[UserCenter sharedInstance] writeRecoverStatusWithFailed:NO];
             [NavigationCenter showWalletPage:self.isRecover createNewWallet:NO];
             [[LockScreenTimeService shareInstance] addObserver];
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            
        }else if(yesOrNo && [ret isKindOfClass:[NSNumber class]]){
            //self.progressView.progress = [ret floatValue];
        }else{
            NSNumber* last_index = (NSNumber*)ret;
            uint64_t lastIndex = [last_index unsignedLongValue];
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:@"token restore failed! retry?" preferredStyle:UIAlertControllerStyleAlert];
            [alertVc addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                [MBHudHelper showTextTips:[LanguageService contentForKey:@"recoveryFailure"] onView:nil withDuration:1.5];
                [self.progressView removeFromSuperview];
                self.progressView = nil;
            }]];
            [alertVc addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self startCheckWallteTokenUtxoFromIndex:lastIndex];
            }]];
            [self.navigationController presentViewController:alertVc animated:YES completion:nil];
        }
    }];
}


- (ProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ProgressView class]) owner:nil options:nil] firstObject];
    }
    return _progressView;
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
