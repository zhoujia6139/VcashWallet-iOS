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
#import "ConfirmSeedphraseViewController.h"

@interface RecoverMnemonicViewController ()

@property (weak, nonatomic) IBOutlet VcashButton *recoverBtn;


@property (weak, nonatomic) IBOutlet UIView *promptView;

@property (weak, nonatomic) IBOutlet VcashLabel *promptLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPromptViewWidth;


@property (weak, nonatomic) IBOutlet UIView *phraseView;

@property (nonatomic, strong) PhraseWordShowViewCreator *creator;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintRecoverBottom;

@property (nonatomic, strong) NSString *password;

@end

@implementation RecoverMnemonicViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = [LanguageService contentForKey:@"restorePhrase"];
    self.constraintPromptViewWidth.constant = ScreenWidth - 24;
    ViewRadius(self.recoverBtn, 4.0);
    
    self.recoverBtn.userInteractionEnabled = NO;
    [self.recoverBtn setBackgroundImage:[UIImage imageWithColor:COrangeEnableColor] forState:UIControlStateNormal];
    self.creator = [PhraseWordShowViewCreator new];
    __weak typeof(self) weakSelf = self;
    NSArray *mnemonicArr = self.recoveryPhrase ? [[[UserCenter sharedInstance] getStoredMnemonicWordsWithKey:self.password] componentsSeparatedByString:@" "] : nil;
    [self.creator creatPhraseViewWithParentView:self.phraseView isCanEdit:!self.recoveryPhrase mnemonicArr:mnemonicArr withCallBack:^(CGFloat height, NSInteger wordsCount){
        __strong typeof(weakSelf) strongSlef = weakSelf;
        if (wordsCount != 24) {
            strongSlef.recoverBtn.userInteractionEnabled = NO;
            [strongSlef.recoverBtn setBackgroundImage:[UIImage imageWithColor:COrangeEnableColor] forState:UIControlStateNormal];
        }else{
            strongSlef.recoverBtn.userInteractionEnabled = YES;
            [strongSlef.recoverBtn setBackgroundImage:[UIImage imageWithColor:COrangeColor] forState:UIControlStateNormal];
        }
    }];
    
    if (self.recoveryPhrase) {
        self.title = [LanguageService contentForKey:@"recoverPhrase"];
        self.promptLabel.text = [LanguageService contentForKey:@"recoveryPhrasePrompt"];
        self.recoverBtn.userInteractionEnabled = YES;
        [self.recoverBtn setBackgroundImage:[UIImage imageWithColor:COrangeColor] forState:UIControlStateNormal];
    }
    self.constraintRecoverBottom.constant = 30 + Portrait_Bottom_SafeArea_Height;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pasteWordsFromClipBoard) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.creator firstTextFieldBecomeFirstResponder];
    [self pasteWordsFromClipBoard];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)setMnemonicKey:(NSString *)key{
    self.password = key;
}

- (void)pasteWordsFromClipBoard{
    if (self.recoveryPhrase) {
        return;
    }
    if ([self.creator getAllInputWords].count == 24) {
        return;
    }
    NSString *pasteString = [UIPasteboard generalPasteboard].string;
    if (pasteString.length > 0) {
        NSArray *mnemonicArr = nil;
        pasteString = [pasteString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        pasteString = [pasteString stringByReplacingOccurrencesOfString:@"-" withString:@" "];
        pasteString = [pasteString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s{2,}" options:NSRegularExpressionCaseInsensitive error:&error];
        
        NSArray *arr = [regex matchesInString:pasteString options:NSMatchingReportCompletion range:NSMakeRange(0, pasteString.length)];
        
        arr = [[arr reverseObjectEnumerator] allObjects];
        
        for (NSTextCheckingResult *str in arr) {
            pasteString = [pasteString stringByReplacingCharactersInRange:[str range] withString:@" "];
        }
        if ([pasteString containsString:@" "]) {
            mnemonicArr = [pasteString componentsSeparatedByString:@" "];
        }
        
        if (mnemonicArr && mnemonicArr.count == 24) {
            UIAlertController *alterVc = [UIAlertController alertControllerWithTitle:[LanguageService contentForKey:@"paste24WordsTitle"] message:@"" preferredStyle:UIAlertControllerStyleAlert];
            [alterVc addAction:[UIAlertAction actionWithTitle:[LanguageService contentForKey:@"cancel"] style:UIAlertActionStyleDefault handler:nil]];
            [alterVc addAction:[UIAlertAction actionWithTitle:[LanguageService contentForKey:@"ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.creator creatPhraseViewWithParentView:self.phraseView isCanEdit:YES mnemonicArr:mnemonicArr withCallBack:^(CGFloat height, NSInteger wordsCount){
                    __weak typeof(self) weakSelf = self;
                    __strong typeof(weakSelf) strongSlef = weakSelf;
                    if (wordsCount != 24) {
                        strongSlef.recoverBtn.userInteractionEnabled = NO;
                        [strongSlef.recoverBtn setBackgroundImage:[UIImage imageWithColor:COrangeEnableColor] forState:UIControlStateNormal];
                    }else{
                        strongSlef.recoverBtn.userInteractionEnabled = YES;
                        [strongSlef.recoverBtn setBackgroundImage:[UIImage imageWithColor:COrangeColor] forState:UIControlStateNormal];
                    }
                }];
                if ([self.creator getAllInputWords].count == 24) {
                    self.recoverBtn.userInteractionEnabled = YES;
                    [self.recoverBtn setBackgroundImage:[UIImage imageWithColor:COrangeColor] forState:UIControlStateNormal];
                }
               
            }]];
            
            [self.navigationController presentViewController:alterVc animated:YES completion:nil];
            
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickRecover:(id)sender {
    if (self.recoveryPhrase) {
        NSArray *mnemonicWordsArr = [[[UserCenter sharedInstance] getStoredMnemonicWordsWithKey:self.password] componentsSeparatedByString:@" "];
        ConfirmSeedphraseViewController *confimSeedPhraseVc = [[ConfirmSeedphraseViewController alloc] init];
        confimSeedPhraseVc.recoveryPhrase = YES;
        confimSeedPhraseVc.mnemonicWordsArr = mnemonicWordsArr;
        [self.navigationController pushViewController:confimSeedPhraseVc animated:YES];
        return;
    }
    NSArray* wordsArr = [self.creator getAllInputWords];
    if (wordsArr.count == 0)
    {
//        //NSString* mnemonicStr = @"glue tilt pair insane enroll scissors galaxy know fringe joke mother zebra";
//        NSString* mnemonicStr = @"layer floor valley flag dawn dress sponsor whale illegal session juice beef scout mammal snake cage river lemon easily away title else layer limit";
//        NSString* mnemonicStr = @"evidence boy green adult kidney biology hollow expire jewel give elegant engine farm photo tomato sustain rigid emerge afford sibling color assume gesture material";
//        wordsArr = [mnemonicStr componentsSeparatedByString:@" "];
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
