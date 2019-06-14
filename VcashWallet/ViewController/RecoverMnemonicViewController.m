//
//  RecoverMnemonicViewController.m
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/1.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "RecoverMnemonicViewController.h"
#import "WalletWrapper.h"
#import "PhraseWordShowViewCreator.h"
#import "PinPasswordSetViewController.h"
#import "WelcomePageViewController.h"

@interface RecoverMnemonicViewController ()

@property (weak, nonatomic) IBOutlet VcashButton *recoverBtn;


@property (weak, nonatomic) IBOutlet UIView *promptView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPromptViewWidth;


@property (weak, nonatomic) IBOutlet UIView *phraseView;

@property (nonatomic, strong) PhraseWordShowViewCreator *creator;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintRecoverBottom;

@end

@implementation RecoverMnemonicViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = [LanguageService contentForKey:@"restorePhrase"];
    self.constraintPromptViewWidth.constant = ScreenWidth - 24;
    ViewRadius(self.recoverBtn, 4.0);
    
    self.recoverBtn.userInteractionEnabled = YES;
    [self.recoverBtn setBackgroundImage:[UIImage imageWithColor:COrangeEnableColor] forState:UIControlStateNormal];
    self.creator = [PhraseWordShowViewCreator new];
    __weak typeof(self) weakSelf = self;
    [self.creator creatPhraseViewWithParentView:self.phraseView isCanEdit:YES withCallBack:^(CGFloat height, NSInteger wordsCount) {
        __strong typeof(weakSelf) strongSlef = weakSelf;
//        if (wordsCount != 24) {
//            strongSlef.recoverBtn.userInteractionEnabled = NO;
//            [strongSlef.recoverBtn setBackgroundImage:[UIImage imageWithColor:COrangeEnableColor] forState:UIControlStateNormal];
//        }else{
//            strongSlef.recoverBtn.userInteractionEnabled = YES;
//            [strongSlef.recoverBtn setBackgroundImage:[UIImage imageWithColor:COrangeColor] forState:UIControlStateNormal];
//        }
    }];
    self.constraintRecoverBottom.constant = 30 + Portrait_Bottom_SafeArea_Height;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.creator firstTextFieldBecomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickRecover:(id)sender {
    NSArray* wordsArr = [self.creator getAllInputWords];
    if (wordsArr.count == 0)
    {
//        //NSString* mnemonicStr = @"glue tilt pair insane enroll scissors galaxy know fringe joke mother zebra";
//        NSString* mnemonicStr = @"layer floor valley flag dawn dress sponsor whale illegal session juice beef scout mammal snake cage river lemon easily away title else layer limit";
        NSString* mnemonicStr = @"evidence boy green adult kidney biology hollow expire jewel give elegant engine farm photo tomato sustain rigid emerge afford sibling color assume gesture material";
        wordsArr = [mnemonicStr componentsSeparatedByString:@" "];
    }
    
    if (wordsArr.count != 24)
    {
        [MBHudHelper showTextTips:[LanguageService contentForKey:@"24valid"] onView:nil withDuration:2];
        return;
    }

    if (wordsArr)
    {
        BOOL createSuc = [WalletWrapper createWalletWithPhrase:wordsArr nickname:nil password:nil];
        if (!createSuc) {
            [self.view makeToast:[LanguageService contentForKey:@"checkSeedPhrase"]];
            return;
        }
        PinPasswordSetViewController*vc = [PinPasswordSetViewController new];
        vc.mnemonicWordsArr = wordsArr;
        vc.isRecover = YES;
        [self.navigationController pushViewController:vc animated:YES];
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
