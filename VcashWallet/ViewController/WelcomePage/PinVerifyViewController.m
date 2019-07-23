//
//  PinVerifyViewController.m
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/17.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "PinVerifyViewController.h"
#import "PinPasswordInputView.h"
#import "RecoverMnemonicViewController.h"
#import "AlertView.h"
#import "LocalAuthenticationManager.h"
#import "LeftMenuManager.h"



@interface PinVerifyViewController ()<PasswordViewDelegate,UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet VcashButton *btnOpenWallet;

@property (weak, nonatomic) IBOutlet VcashTextField *textFieldPassword;

@property (weak, nonatomic) IBOutlet UIView *viewLine;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImageBgTop;

@property (weak, nonatomic) IBOutlet VcashLabel *labelPrompt;

@property (weak, nonatomic) IBOutlet VcashLabel *labelPasswordWrong;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewEye;

@property (nonatomic, assign) BOOL openEye;

@property (weak, nonatomic) IBOutlet VcashButton *btnRestore;


@property (weak, nonatomic) IBOutlet UIButton *btnTouchId;

@property (weak, nonatomic) IBOutlet UILabel *labelTouchId;

@end

@implementation PinVerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.textFieldPassword setValue:[UIColor colorWithHexString:@"#666666"] forKeyPath:@"_placeholderLabel.textColor"];
    self.textFieldPassword.tintColor = COrangeColor;
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 40)];
    self.textFieldPassword.rightView = rightView;
    self.textFieldPassword.rightViewMode = UITextFieldViewModeAlways;
    [self.textFieldPassword addTarget:self action:@selector(enterPassword:) forControlEvents:UIControlEventEditingChanged];
    [self.btnOpenWallet setBackgroundImage:[UIImage imageWithColor:COrangeColor] forState:UIControlStateNormal];
    [self.btnOpenWallet setBackgroundImage:[UIImage imageWithColor:COrangeHighlightedColor] forState:UIControlStateHighlighted];
    [self.btnTouchId setImage:[UIImage imageNamed:@"touchid.png"] forState:UIControlStateNormal];
    ViewRadius(self.btnOpenWallet, 4.0);
    self.textFieldPassword.delegate  = self;
    self.constraintImageBgTop.constant = kTopHeight;
    self.imageViewEye.userInteractionEnabled = YES;
    __weak typeof(self) weakSelf  = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.openEye = !strongSelf.openEye;
        strongSelf.imageViewEye.image = strongSelf.openEye ?  [UIImage imageNamed:@"eyeopen.png"] : [UIImage imageNamed:@"eyeclose.png"];
        strongSelf.textFieldPassword.secureTextEntry = !strongSelf.openEye;
    }];
    [self.imageViewEye addGestureRecognizer:tap];
    self.btnRestore.hidden = self.startTouch;
    self.btnTouchId.hidden = !self.startTouch;
    self.labelTouchId.hidden = !self.startTouch;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.startTouch) {
        [self verifyIdentifier];
    }
}


- (BOOL)prefersStatusBarHidden{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)enterPassword:(UITextField *)textField{
    if (textField.text.length == 0) {
        self.viewLine.backgroundColor = COrangeColor;
        self.labelPasswordWrong.hidden = YES;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.labelPrompt.textColor = [UIColor colorWithHexString:@"#666666"];
    self.viewLine.backgroundColor = COrangeColor;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.labelPrompt.textColor = [UIColor whiteColor];
    self.viewLine.backgroundColor = [UIColor colorWithHexString:@"#666666"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)clickedTouchId:(id)sender {
    [self verifyIdentifier];
}


- (IBAction)clickedEnterWallet:(id)sender {
    [self checkPassword:self.textFieldPassword.text];
}

- (void)verifyIdentifier{
    __weak typeof(self) weakSelf = self;
    [self.btnTouchId setImage:[UIImage imageNamed:@"touchid.png"] forState:UIControlStateNormal];
    [[LocalAuthenticationManager shareInstance] verifyIdentidyWithComplete:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            [weakSelf dismissViewControllerAnimated:NO completion:^{
                UIViewController *currentVc = [[AppHelper shareInstance] visibleViewController];
                if ([currentVc isKindOfClass:NSClassFromString(@"WalletViewController")] ||[currentVc isKindOfClass:NSClassFromString(@"SettingViewController")] || [currentVc isKindOfClass:NSClassFromString(@"AddressBookViewController")]) {
                    [[LeftMenuManager shareInstance] addGestures];
                }
            }];
           
        }else{
            if (@available(iOS 11.0, *)) {
                if (error.code == LAErrorAuthenticationFailed || error.code == LAErrorTouchIDLockout || error.code == LAErrorBiometryLockout) {
                    [self.btnTouchId setImage:[UIImage imageNamed:@"touchidseleted.png"] forState:UIControlStateNormal];
                }
            } else {
                // Fallback on earlier versions
                if (error.code == LAErrorAuthenticationFailed || error.code == LAErrorTouchIDLockout) {
                    [self.btnTouchId setImage:[UIImage imageNamed:@"touchidseleted.png"] forState:UIControlStateNormal];
                }
            }
        }
    }];
}

-(void)checkPassword:(NSString*)password
{
    NSString* monenicWords = [[UserCenter sharedInstance] getStoredMnemonicWordsWithKey:password];
    NSArray* wordsArr = [monenicWords componentsSeparatedByString:@" "];
    BOOL yesOrNO = [WalletWrapper createWalletWithPhrase:wordsArr nickname:nil password:nil];
    if (yesOrNO)
    {
        self.labelPasswordWrong.hidden = YES;
        [NavigationCenter showWalletPage:NO createNewWallet:NO];
    }
    else
    {
        DDLogWarn(@"-------mnemonioc words in keychain is not available");
        self.labelPasswordWrong.hidden = NO;
        NSString *tips = password.length > 0 ? [LanguageService contentForKey:@"passwordIsWrong"] : [LanguageService contentForKey:@"fillPasswordWarning"];
        self.labelPasswordWrong.text = tips;
        self.viewLine.backgroundColor = [UIColor colorWithHexString:@"#FF3333"];
    }
}

- (IBAction)clickedRestoreWallet:(id)sender {
    AlertView *alterView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([AlertView class]) owner:nil options:nil] firstObject];
    alterView.title =  [LanguageService contentForKey:@"warning"];
    alterView.msg = [LanguageService contentForKey:@"recoverWalletWarning"];
    alterView.doneTitle = [LanguageService contentForKey:@"doneTitle"];
    __weak typeof(self) weakSelf = self;
    alterView.doneCallBack = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
         [strongSelf.navigationController pushViewController:[RecoverMnemonicViewController new] animated:YES];
    };
    [alterView show];
   
}


-(void)PinPasswordView:(PinPasswordInputView*)inputview didGetPassword:(NSString*)password
{
    [self checkPassword:password];
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
