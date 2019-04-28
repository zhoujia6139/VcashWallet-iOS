//
//  PinPasswordSetViewController.m
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/16.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "PinPasswordSetViewController.h"
#import "PinPasswordInputView.h"

@interface PinPasswordSetViewController ()<PasswordViewDelegate>

@property (nonatomic, strong) PinPasswordInputView *pasView;

@end

@implementation PinPasswordSetViewController
{
    NSString* firstPass;
    NSString* secondPass;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"密码设置";
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
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.pasView openKeyboard];
}

- (void)btnAction
{
    NSString* inputStr = [self.pasView getInput];
    if (inputStr.length != 6)
    {
        [MBHudHelper showTextTips:@"请重新输入6位数字" onView:nil withDuration:1.5];
        return;
    }

    
}

-(void)PinPasswordView:(PinPasswordInputView*)inputview didGetPassword:(NSString*)password
{
    if (!firstPass)
    {
        firstPass = [self.pasView getInput];
        [self.pasView clearUpPassword];
        [MBHudHelper showTextTips:@"请再次输入" onView:nil withDuration:1.5];
        return;
    }
    
    if (!secondPass)
    {
        secondPass  = [self.pasView getInput];
        if ([firstPass isEqualToString:secondPass])
        {
            BOOL yesOrNo = [WalletWrapper createWalletWithPhrase:self.mnemonicWordsArr nickname:nil password:nil];
            if (yesOrNo)
            {
                NSString* wordStr = [self.mnemonicWordsArr componentsJoinedByString:@" "];
                [[UserCenter sharedInstance] storeMnemonicWords:wordStr withKey:firstPass];
                [NavigationCenter showWalletPage:self.isRecover];
            }
        }
        else
        {
            firstPass = nil;
            secondPass = nil;
            [self.pasView clearUpPassword];
            [MBHudHelper showTextTips:@"两次输入不一致，请重新输入" onView:nil withDuration:1.5];
        }
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
