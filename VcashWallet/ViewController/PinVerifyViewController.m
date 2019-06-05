//
//  PinVerifyViewController.m
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/17.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "PinVerifyViewController.h"
#import "PinPasswordInputView.h"



@interface PinVerifyViewController ()<PasswordViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet VcashButton *btnOpenWallet;


@property (weak, nonatomic) IBOutlet VcashTextField *textFieldPassword;

@property (weak, nonatomic) IBOutlet UIView *viewLine;

@property (nonatomic, strong) PinPasswordInputView *pasView;

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
    UIButton* btn = [[UIButton alloc] init];
    [btn setTitle:[LanguageService contentForKey:@"restoreWallet"] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(resetWallet) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(28);
        make.right.equalTo(self.view).offset(-28);
        make.bottom.equalTo(self.view).offset(-50);
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor blackColor]] forBarMetrics:UIBarMetricsDefault];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
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
    self.viewLine.backgroundColor = [UIColor whiteColor];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.viewLine.backgroundColor = CGrayColor;
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
        [NavigationCenter showWalletPage:NO];
    }
    else
    {
        DDLogWarn(@"-------mnemonioc words in keychain is not available");
        [MBHudHelper showTextTips:[LanguageService contentForKey:@"passwordIsWrong"] onView:nil withDuration:1.5];
        [self.pasView clearUpPassword];
    }
}

-(void)resetWallet
{
    [WalletWrapper clearWallet];
    [NavigationCenter showWelcomePage];
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
