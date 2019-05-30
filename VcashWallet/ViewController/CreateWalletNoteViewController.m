//
//  CreateWalletNoteViewController.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/22.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "CreateWalletNoteViewController.h"
#import "CreateMnemonicViewController.h"

@interface CreateWalletNoteViewController ()

@property (weak, nonatomic) IBOutlet VcashButton *agreeBtn;


@end

@implementation CreateWalletNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = [LanguageService contentForKey:@"createNewWalletTitle"];
    ViewRadius(self.agreeBtn, 4.0);
    
}

- (IBAction)clickedBtnAgree:(id)sender {
     [self.navigationController pushViewController:[CreateMnemonicViewController new] animated:YES];
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
