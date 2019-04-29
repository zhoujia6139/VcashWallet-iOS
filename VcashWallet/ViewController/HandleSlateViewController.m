//
//  HandleSlateViewController.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/29.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "HandleSlateViewController.h"
#import "VcashSlate.h"

@interface HandleSlateViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation HandleSlateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)clickReceive:(id)sender {
    NSString* text = self.textView.text;
    VcashSlate* slate = [VcashSlate modelWithJSON:text];
    if (slate){
        [WalletWrapper receiveTransaction:slate];
    }
}

- (IBAction)clickSend:(id)sender {
    NSString* text = self.textView.text;
    VcashSlate* slate = [VcashSlate modelWithJSON:text];
    if (slate){
        [WalletWrapper finalizeTransaction:slate];
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
