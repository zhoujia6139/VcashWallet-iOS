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
@property (weak, nonatomic) IBOutlet UIView *phraseView;

@end

@implementation RecoverMnemonicViewController
{
    PhraseWordShowViewCreator*creator;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"恢复钱包";
    
    creator = [PhraseWordShowViewCreator new];
    [creator creatPhraseViewWithParentView:self.phraseView isCanEdit:YES withCallBack:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clickRecover:(id)sender {
    NSArray* wordsArr = [creator getAllInputWords];
    if (wordsArr.count == 0)
    {
        //NSString* mnemonicStr = @"glue tilt pair insane enroll scissors galaxy know fringe joke mother zebra";
        NSString* mnemonicStr = @"layer floor valley flag dawn dress sponsor whale illegal session juice beef scout mammal snake cage river lemon easily away title else layer limit";
        wordsArr = [mnemonicStr componentsSeparatedByString:@" "];
    }
    
    if (wordsArr.count != 24)
    {
        [MBHudHelper showTextTips:@"请输入24个有效的单词" onView:nil withDuration:2];
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
