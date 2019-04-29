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
//#import "MnemonicVerifyViewController.h"

@interface CreateMnemonicViewController ()

@property (weak, nonatomic) IBOutlet UIView *phraseWordView;

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
    self.navigationItem.title = @"创建钱包";
    creator = [PhraseWordShowViewCreator new];
    [creator creatPhraseViewWithParentView:self.phraseWordView isCanEdit:NO withCallBack:nil];

    [self refreshPharseView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didTakeScreenshot) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
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
    [MBHudHelper showTextTips:@"助记词已变更，请重新备份" onView:nil withDuration:5];
}

- (IBAction)clickedWalletBtn:(id)sender {
    NSArray* wordsArr = [creator getAllInputWords];
    PinPasswordSetViewController*vc = [PinPasswordSetViewController new];
    vc.mnemonicWordsArr = wordsArr;
    [self.navigationController pushViewController:vc animated:YES];
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
