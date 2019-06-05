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

@interface RecoverMnemonicViewController ()

@property (weak, nonatomic) IBOutlet VcashButton *recoverBtn;


@property (weak, nonatomic) IBOutlet UIView *promptView;

@property (weak, nonatomic) IBOutlet UIView *phraseView;

@property (nonatomic, strong) PhraseWordShowViewCreator *creator;

@end

@implementation RecoverMnemonicViewController
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [LanguageService contentForKey:@"restorePhrase"];
    ViewRadius(self.recoverBtn, 4.0);
//    self.recoverBtn.userInteractionEnabled = NO;
//    self.recoverBtn.backgroundColor = CGrayColor;
    self.creator = [PhraseWordShowViewCreator new];
    __weak typeof(self) weakSelf = self;
    [self.creator creatPhraseViewWithParentView:self.phraseView isCanEdit:YES withCallBack:^(CGFloat height, NSInteger wordsCount) {
//        __strong typeof(weakSelf) strongSlef = weakSelf;
//        if (wordsCount != 24) {
//            strongSlef.recoverBtn.userInteractionEnabled = NO;
//            strongSlef.recoverBtn.backgroundColor = CGrayColor;
//        }else{
//            strongSlef.recoverBtn.userInteractionEnabled = YES;
//           strongSlef.recoverBtn.backgroundColor = COrangeColor;
//        }
    }];
    // Do any additional setup after loading the view from its nib.
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
        NSString* mnemonicStr = @"layer floor valley flag dawn dress sponsor whale illegal session juice beef scout mammal snake cage river lemon easily away title else layer limit";
        wordsArr = [mnemonicStr componentsSeparatedByString:@" "];
    }
    
    if (wordsArr.count != 24)
    {
        [MBHudHelper showTextTips:[LanguageService contentForKey:@"24valid"] onView:nil withDuration:2];
        return;
    }

    if (wordsArr)
    {
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
