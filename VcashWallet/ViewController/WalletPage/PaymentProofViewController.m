//
//  PaymentProofViewController.m
//  VcashWallet
//
//  Created by jia zhou on 2020/5/12.
//  Copyright © 2020 blockin. All rights reserved.
//

#import "PaymentProofViewController.h"

@interface PaymentProofViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation PaymentProofViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.textView.text = self.proof;
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
