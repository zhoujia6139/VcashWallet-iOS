//
//  SettingViewController.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/28.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "SettingViewController.h"
#import "ChangePasswordViewController.h"

@interface SettingViewController ()


@property (weak, nonatomic) IBOutlet UIView *viewLockScreen;


@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = [LanguageService contentForKey:@"setting"];
    [AppHelper addLineWithParentView:self.viewLockScreen];
}



- (IBAction)clickedBtnLockScreen:(id)sender {
    
}


- (IBAction)clickedBtnChangeWalletPassword:(id)sender {
    ChangePasswordViewController *changePwVc = [[ChangePasswordViewController alloc] init];
    [self.navigationController pushViewController:changePwVc animated:YES];
}


- (IBAction)clickedBtnReport:(id)sender {
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
