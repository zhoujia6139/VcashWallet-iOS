//
//  CreateMnemonicViewController.m
//  PoolinWallet
//
//  Created by jia zhou on 2018/7/31.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "CreateMnemonicViewController.h"
#import "WalletWrapper.h"
//#import "WalletViewController.h"
//#import "UnspentTransaction.h"
//#import "AddressTransactionDataService.h"
#import "PhraseWordShowViewCreator.h"
#import "PinPasswordSetViewController.h"
#import "AlertView.h"
#import "ConfirmSeedphraseViewController.h"
//#import "MnemonicVerifyViewController.h"

@interface CreateMnemonicViewController ()

@property (weak, nonatomic) IBOutlet UIView *promptView;

@property (weak, nonatomic) IBOutlet UIView *phraseWordView;

@property (weak, nonatomic) IBOutlet VcashButton *nextBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *copnstraintPromptView;

@end

@implementation CreateMnemonicViewController{
    NSString *_destinationAddress;
    //BTCAmount selectedFees;
    NSString *_changeAddress;
    //BTCKey *privateKey;
    PhraseWordShowViewCreator*creator;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [LanguageService contentForKey:@"seedPhrase"];
    self.copnstraintPromptView.constant = ScreenWidth - 24;
    ViewRadius(self.promptView, 4.0);
    ViewRadius(self.nextBtn, 4.0);
    [self.nextBtn setBackgroundImage:[UIImage imageWithColor:COrangeColor] forState:UIControlStateNormal];
    [self.nextBtn setBackgroundImage:[UIImage imageWithColor:COrangeHighlightedColor] forState:UIControlStateHighlighted];
    creator = [PhraseWordShowViewCreator new];
    [creator creatPhraseViewWithParentView:self.phraseWordView isCanEdit:NO withCallBack:nil];

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didTakeScreenshot) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     [self refreshPharseView];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)refreshPharseView
{
    NSArray* wordsArr = [WalletWrapper generateMnemonicPassphrase];
    [creator setInputWordsArray:wordsArr];
}

-(void)didTakeScreenshot
{
    [self refreshPharseView];
    [MBHudHelper showTextTips:[LanguageService contentForKey:@"mnemonicChangeedBackup"] onView:nil withDuration:5];
}

- (IBAction)clickedWalletBtn:(id)sender {
    
//    AlertView *alertView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([AlertView class]) owner:nil options:nil] firstObject];
    __weak typeof(self) weakSelf = self;
//    alertView.doneCallBack = ^{
//        __strong typeof(weakSelf) strongSelf = weakSelf;
//        [strongSelf pushConfirmPhraseVc];
//    };
//    [alertView show];
    
    UIAlertController *alterVc = [UIAlertController alertControllerWithTitle:[LanguageService contentForKey:@"saveSeedphrase"] message:[LanguageService contentForKey:@"saveSeedphraseContent"] preferredStyle:UIAlertControllerStyleAlert];
    
    [alterVc addAction:[UIAlertAction actionWithTitle:[LanguageService contentForKey:@"cancel"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [alterVc addAction:[UIAlertAction actionWithTitle:[LanguageService contentForKey:@"done"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf pushConfirmPhraseVc];
    }]];
   
    [self.navigationController presentViewController:alterVc animated:YES completion:nil];
}

- (void)pushConfirmPhraseVc{
    NSArray* wordsArr = [creator getAllInputWords];
    ConfirmSeedphraseViewController *confirmPhraseVc = [ConfirmSeedphraseViewController new];
    confirmPhraseVc.mnemonicWordsArr = wordsArr;
    [self.navigationController pushViewController:confirmPhraseVc animated:YES];
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
