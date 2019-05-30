//
//  WelcomePageViewController.m
//  PoolinWallet
//
//  Created by jia zhou on 2018/7/31.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "WelcomePageViewController.h"
#import "CreateWalletNoteViewController.h"
#import "RecoverMnemonicViewController.h"

@interface WelcomePageViewController ()


@property (weak, nonatomic) IBOutlet VcashButton *createNewWalletBtn;

@property (weak, nonatomic) IBOutlet VcashButton *restoreWalletBtn;


@end

@implementation WelcomePageViewController{
    UIButton *seletedBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ViewRadius(self.createNewWalletBtn, 8.0);
    ViewBorderRadius(self.restoreWalletBtn, 8.0, 1, [UIColor whiteColor]);
    self.createNewWalletBtn.backgroundColor = [UIColor colorWithHexString:@"FF9502"];
    self.restoreWalletBtn.backgroundColor = [UIColor blackColor];
//    [self.createNewWalletBtn setBackgroundImage:[UIImage imageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
//    [self.createNewWalletBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"FF9502"]] forState:UIControlStateSelected];
//    self.createNewWalletBtn.selected = YES;
    seletedBtn = self.createNewWalletBtn;
//    [self.restoreWalletBtn setBackgroundImage:[UIImage imageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
//    [self.restoreWalletBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"FF9502"]] forState:UIControlStateSelected];
    
//    NSString* mnemonicStr = @"glue tilt pair insane enroll scissors galaxy know fringe joke mother zebra";
//    NSArray* wordsArr = [mnemonicStr componentsSeparatedByString:@" "];
//    [WalletWrapper createWalletWithPhrase:wordsArr nickname:@"zhoujia" password:nil];
//    NSString* address1 = [WalletWrapper getCurAccountAddress];
//    NSLog(@"---------------%@",address1);//mgt52P3kkkPLYJvvUNwva4MwGYF5zqTgA9
//    [WalletWrapper createNewAddressForCurAccount];
//    NSString* address2 = [WalletWrapper getCurAccountNextAddress];
//    NSLog(@"---------------%@",address2);//mxwcqnJCdpLxMmNwy6YYvSJkPyFzzSM9HJ
//    [WalletWrapper requestAllTransactionForCurAccountWithComplete:^(BOOL yesOrNo, NSString* message){
//        CGFloat total = [WalletWrapper getBalanceForCurAccount];
//        NSLog(@"---------------%f",total);
//
//
//        [WalletWrapper sendTransactionForAddress:@"2N8hwP1WmJrFF5QWABn38y63uYLhnJYJYTF" andPayAmount:0.2 andFeeAmount:0.1 WithComplete:^(BOOL yesOrNo, NSString *errmsg) {
//            NSLog(@"111111111111111111111=%@", errmsg);
//        }];
//    }];
    

    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickCreate:(id)sender {
    [self switchBtnBackGroudColorWith:sender];
    [self.navigationController pushViewController:[CreateWalletNoteViewController new] animated:YES];
}

- (IBAction)clickRestore:(id)sender {
    [self switchBtnBackGroudColorWith:sender];
    [self.navigationController pushViewController:[RecoverMnemonicViewController new] animated:YES];
}

- (void)switchBtnBackGroudColorWith:(UIButton *)btn{
    if (seletedBtn == btn) {
        return;
    }
    seletedBtn.backgroundColor = [UIColor blackColor];
    btn.backgroundColor = [UIColor colorWithHexString:@"FF9502"];
    seletedBtn = btn;
    ViewBorderRadius(btn, 8.0,0,[UIColor clearColor]);
   
    if (btn != self.createNewWalletBtn) {
         ViewBorderRadius(self.createNewWalletBtn, 8.0, 1, [UIColor whiteColor]);
    }
    
    if (btn != self.restoreWalletBtn) {
         ViewBorderRadius(self.restoreWalletBtn, 8.0, 1, [UIColor whiteColor]);
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
