//
//  SettingViewController.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/28.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "SettingViewController.h"
#import "ChangePasswordViewController.h"
#import "LockScreenSetViewController.h"
#import "LockScreenTimeService.h"

@interface SettingViewController ()


@property (weak, nonatomic) IBOutlet UIView *viewLockScreen;

@property (weak, nonatomic) IBOutlet UIButton *btnLockScreen;

@property (weak, nonatomic) IBOutlet UILabel *labelLockScreenTitle;

@property (weak, nonatomic) IBOutlet UIButton *btnChangePassword;

@property (weak, nonatomic) IBOutlet UILabel *labelVersion;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = [LanguageService contentForKey:@"setting"];
    [AppHelper addLineWithParentView:self.viewLockScreen];
    [self.btnLockScreen setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#9C9D9D"]] forState:UIControlStateHighlighted];
    [self.btnChangePassword setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#9C9D9D"]] forState:UIControlStateHighlighted];
    self.labelVersion.text = [NSString stringWithFormat:@"App Version:%@",AppVersion];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.isShowLeftBack = NO;
    self.isShowLeftMeue = YES;
    LockScreenType lockScreenType = [[LockScreenTimeService shareInstance] readLockScreenType];
    NSString *lockScreenTitle;
    switch (lockScreenType) {
        case LockScreenType3Minute:
            lockScreenTitle = [LanguageService contentForKey:@"after3Minute"];
            break;
        case LockScreenTypeNever:
            lockScreenTitle = [LanguageService contentForKey:@"never"];
            break;
            
        case LockScreenType30Seonds:
            lockScreenTitle = [LanguageService contentForKey:@"after30Seconds"];
            break;
            
        case LockScreenType1Minute:
            lockScreenTitle = [LanguageService contentForKey:@"after1Minute"];
            break;
            
        default:
            break;
    }
    self.labelLockScreenTitle.text = lockScreenTitle;
}



- (IBAction)clickedBtnLockScreen:(id)sender {
    LockScreenSetViewController *lockScreenSetVc = [[LockScreenSetViewController alloc] init];
    [self.navigationController pushViewController:lockScreenSetVc animated:YES];
}


- (IBAction)clickedBtnChangeWalletPassword:(id)sender {
    ChangePasswordViewController *changePwVc = [[ChangePasswordViewController alloc] init];
    [self.navigationController pushViewController:changePwVc animated:YES];
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
