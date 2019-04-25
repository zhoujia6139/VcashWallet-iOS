//
//  PinVerifyViewController.m
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/17.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "PinVerifyViewController.h"
#import "PinPasswordInputView.h"

@interface PinVerifyViewController ()<PasswordViewDelegate>

@property (nonatomic, strong) PinPasswordInputView *pasView;

@end

@implementation PinVerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"密码验证";
    self.view.backgroundColor = [UIColor colorWithRed:230 / 250.0 green:230 / 250.0 blue:230 / 250.0 alpha:1.0];
    self.navigationController.navigationBar.translucent = NO;
    
    self.pasView = [[PinPasswordInputView alloc] initWithFrame:CGRectMake(16, 100, self.view.frame.size.width - 32, 45)];
    self.pasView.delegate = self;
    [self.view addSubview:_pasView];
    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.backgroundColor = [UIColor brownColor];
//    button.frame = CGRectMake(100, 180, self.view.frame.size.width - 200, 50);
//    [button addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
//    [button setTitle:@"确定" forState:UIControlStateNormal];
//    [self.view addSubview:button];
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake((ScreenWidth-140)/2, (ScreenHeight/2-50), 140, 40)];
    [btn setTitle:@"重新恢复钱包" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(resetWallet) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.pasView openKeyboard];
}

-(void)checkPassword:(NSString*)password
{
    NSString* monenicWords = [[UserCenter sharedInstance] getStoredMnemonicWordsWithKey:password];
    NSArray* wordsArr = [monenicWords componentsSeparatedByString:@" "];
    BOOL yesOrNO = [WalletWrapper createWalletWithPhrase:wordsArr nickname:nil password:nil];
    if (yesOrNO)
    {
        
        VcashSlate*slate = [WalletWrapper createSendTransaction:@"" amount:1000000000 fee:0 withComplete:^(BOOL yesOrNO, id data) {
            
        }];
        
        [NavigationCenter showWalletPage];
    }
    else
    {
        DDLogWarn(@"-------mnemonioc words in keychain is not available");
        [MBHudHelper showTextTips:@"密码不对" onView:nil withDuration:1.5];
        [self.pasView clearUpPassword];
    }
}

-(void)resetWallet
{
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
