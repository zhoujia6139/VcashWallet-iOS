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
#import "AlertView.h"

@interface WelcomePageViewController ()


@property (weak, nonatomic) IBOutlet VcashButton *createNewWalletBtn;

@property (weak, nonatomic) IBOutlet VcashButton *restoreWalletBtn;


@end

@implementation WelcomePageViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    ViewRadius(self.createNewWalletBtn, 8.0);
    ViewBorderRadius(self.restoreWalletBtn, 8.0, 1, [UIColor whiteColor]);
    
    [self.createNewWalletBtn setBackgroundImage:[UIImage imageWithColor:COrangeColor] forState:UIControlStateNormal];
    [self.createNewWalletBtn setBackgroundImage:[UIImage imageWithColor:COrangeHighlightedColor] forState:UIControlStateHighlighted];
    
    self.restoreWalletBtn.backgroundColor = [UIColor blackColor];
    [self.restoreWalletBtn setBackgroundImage:[UIImage imageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
    [self.restoreWalletBtn setBackgroundImage:[UIImage imageWithColor:CGrayHighlightedColor] forState:UIControlStateHighlighted];
    // Do any additional setup after loading the view from its nib.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.restoreWalletBtn addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.restoreWalletBtn removeObserver:self forKeyPath:@"highlighted"];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"highlighted"]) {
        if (self.restoreWalletBtn.state == UIControlStateNormal) {
            ViewBorderRadius(self.restoreWalletBtn, 8.0, 1, [UIColor whiteColor]);
        }else{
            ViewBorderRadius(self.restoreWalletBtn, 8.0, 0, [UIColor whiteColor]);
        }
    }
}


- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickCreate:(id)sender {
    [self.navigationController pushViewController:[CreateWalletNoteViewController new] animated:YES];
}

- (IBAction)clickRestore:(id)sender {
    AlertView *alterView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([AlertView class]) owner:nil options:nil] firstObject];
    alterView.title =  [LanguageService contentForKey:@"warning"];
    alterView.msg = [LanguageService contentForKey:@"recoverWalletWarning"];
    alterView.doneTitle = [LanguageService contentForKey:@"doneTitle"];
    __weak typeof(self) weakSelf = self;
    alterView.doneCallBack = ^{
        [[UserCenter sharedInstance] clearWallet];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.navigationController pushViewController:[RecoverMnemonicViewController new] animated:YES];
    };
    [alterView show];
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
