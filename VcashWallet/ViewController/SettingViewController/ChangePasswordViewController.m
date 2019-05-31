//
//  ChangePasswordViewController.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/29.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "PinPasswordSetViewController.h"

@interface ChangePasswordViewController ()

@property (weak, nonatomic) IBOutlet VcashButton *btnNext;

@property (weak, nonatomic) IBOutlet VcashTextField *textFieldPassword;

@property (weak, nonatomic) IBOutlet VcashLabel *labelPrompt;


@property (weak, nonatomic) IBOutlet UIView *viewLine;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = [LanguageService contentForKey:@"changePw"];
    ViewRadius(self.btnNext, 4.0);
    self.btnNext.userInteractionEnabled = NO;
    self.btnNext.backgroundColor = CGrayColor;
    [self.textFieldPassword addTarget:self action:@selector(enterCurrentPassword:) forControlEvents:UIControlEventEditingChanged];
}

- (void)enterCurrentPassword:(UITextField *)textField{
    if (textField.text.length > 0) {
        self.btnNext.userInteractionEnabled = YES;
        self.btnNext.backgroundColor = COrangeColor;
    }else{
        self.btnNext.userInteractionEnabled = NO;
        self.btnNext.backgroundColor = CGrayColor;
    }
}

- (IBAction)clickedBtnVerifuCurrentPassword:(id)sender {
   NSString *retStr =  [[UserCenter sharedInstance] getStoredMnemonicWordsWithKey:self.textFieldPassword.text];
    if (!retStr) {
        self.labelPrompt.hidden = NO;
        self.viewLine.backgroundColor = [UIColor colorWithHexString:@"#FF3333"];
        self.textFieldPassword.textColor = [UIColor colorWithHexString:@"#FF3333"];
    }else{
        self.labelPrompt.hidden = YES;
        self.viewLine.backgroundColor = [UIColor colorWithHexString:@"#EEEEEE"];
        self.textFieldPassword.textColor = [UIColor darkTextColor];
        PinPasswordSetViewController *passwordSetVc = [[PinPasswordSetViewController alloc] init];
        passwordSetVc.isChangePassword = YES;
        passwordSetVc.currentPassword = self.textFieldPassword.text;
        [self.navigationController pushViewController:passwordSetVc animated:YES];
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
