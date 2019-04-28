//
//  SendTransactionViewController.m
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/3.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "SendTransactionViewController.h"
#import "WalletWrapper.h"
#import "SendTransactionConfirmView.h"

@interface SendTransactionViewController ()
@property (weak, nonatomic) IBOutlet UITextField *targetAddressField;

@property (weak, nonatomic) IBOutlet UITextField *amountField;

@end

@implementation SendTransactionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"发送Vcash";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickSend:(id)sender {
    NSString* strAmount = self.amountField.text;
    NSNumber* numberAmount = [NSNumber numberWithString:strAmount];
    double amount = [numberAmount doubleValue];
    if (self.targetAddressField.text && amount > 0)
    {
        VcashSlate* slate = [WalletWrapper createSendTransaction:self.targetAddressField.text amount:[WalletWrapper vcashToNano:amount] fee:0 withComplete:^(BOOL yesOrNo, id retData) {
            
        }];
        SendTransactionConfirmView* confirmView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([SendTransactionConfirmView class]) owner:self options:nil][0];
        [confirmView setReceiverId:self.targetAddressField.text andSlate:slate];
        UIView* window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:confirmView];
        [confirmView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(window);
        }];
    }
}

//- (IBAction)clickContract:(id)sender {
//    [self.navigationController pushViewController:[MyContractViewController new] animated:YES];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
