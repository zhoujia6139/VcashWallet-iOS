//
//  TransactionFileSignedRecordViewController.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/7/1.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "TransactionFileSignedRecordViewController.h"
#import "WalletCell.h"
#import "ReceiverSignTransactionFileViewController.h"

static NSString *const identifier = @"WalletCell";

@interface TransactionFileSignedRecordViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *arrData;


@end

@implementation TransactionFileSignedRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.arrData = [WalletWrapper getFileReceiveTxArr];
    [self configView];
}

- (void)configView{
    self.title = [LanguageService contentForKey:@"txFileSignedRecordTitle"];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WalletCell class]) bundle:nil] forCellReuseIdentifier:identifier];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WalletCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 73;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    VcashTxLog *txLog = self.arrData[indexPath.row];
    ReceiverSignTransactionFileViewController *signTxFileVc = [[ReceiverSignTransactionFileViewController alloc] init];
    signTxFileVc.txLog = txLog;
    [self.navigationController pushViewController:signTxFileVc animated:YES];
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
