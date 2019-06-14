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



@interface PinVerifyViewController ()<PasswordViewDelegate,UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet VcashButton *btnOpenWallet;

@property (weak, nonatomic) IBOutlet VcashTextField *textFieldPassword;

@property (weak, nonatomic) IBOutlet UIView *viewLine;

@property (nonatomic, strong) PinPasswordInputView *pasView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImageBgTop;

@property (weak, nonatomic) IBOutlet VcashLabel *labelPrompt;

@property (weak, nonatomic) IBOutlet VcashLabel *labelPasswordWrong;


@end

@implementation PinVerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.textFieldPassword setValue:[UIColor colorWithHexString:@"#666666"] forKeyPath:@"_placeholderLabel.textColor"];
    self.textFieldPassword.tintColor = [UIColor whiteColor];
    [self.btnOpenWallet setBackgroundImage:[UIImage imageWithColor:COrangeColor] forState:UIControlStateNormal];
    [self.btnOpenWallet setBackgroundImage:[UIImage imageWithColor:COrangeHighlightedColor] forState:UIControlStateHighlighted];
    ViewRadius(self.btnOpenWallet, 4.0);
    self.textFieldPassword.delegate  = self;
    self.constraintImageBgTop.constant = kTopHeight;
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
    [self.pasView openKeyboard];
}


- (BOOL)prefersStatusBarHidden{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.labelPrompt.textColor = [UIColor colorWithHexString:@"#666666"];
    self.viewLine.backgroundColor = [UIColor whiteColor];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.labelPrompt.textColor = [UIColor whiteColor];
    self.viewLine.backgroundColor = [UIColor colorWithHexString:@"#666666"];
}


- (IBAction)clickedEnterWallet:(id)sender {
    [self checkPassword:self.textFieldPassword.text];
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
        self.viewLine.backgroundColor = [UIColor colorWithHexString:@"#FF3333"];
        [self.pasView clearUpPassword];
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

- (void)btnAction
{
    NSString* password = [self.pasView getInput];
    [self checkPassword:password];
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
