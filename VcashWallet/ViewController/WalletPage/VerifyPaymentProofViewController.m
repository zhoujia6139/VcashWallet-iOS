//
//  VerifyPaymentProofViewController.m
//  VcashWallet
//
//  Created by jia zhou on 2020/5/12.
//  Copyright © 2020 blockin. All rights reserved.
//

#import "VerifyPaymentProofViewController.h"

@interface VerifyPaymentProofViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation VerifyPaymentProofViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.text = @"";
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)clickVerify:(id)sender {
    if (self.textView.text) {
        NSString* ret = [WalletWrapper verifyPaymentProof:self.textView.text];
        if (ret.length > 0) {
            [MBHudHelper showTextTips:ret onView:nil withDuration:1.0];
        }
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
