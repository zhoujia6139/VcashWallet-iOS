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

@property (weak, nonatomic) IBOutlet UIView *noDataView;

@end

@implementation TransactionFileSignedRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSArray *array = [WalletWrapper getFileReceiveTxArr];
    self.arrData = [array sortedArrayUsingComparator:^NSComparisonResult(VcashTxLog *obj1, VcashTxLog *obj2) {
        return [@(obj2.create_time) compare:@(obj1.create_time)];
    }];
    [self configView];
}

- (void)configView{
    self.title = [LanguageService contentForKey:@"txFileSignedRecordTitle"];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WalletCell class]) bundle:nil] forCellReuseIdentifier:identifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.noDataView.hidden  = self.arrData.count > 0 ? YES : NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WalletCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (indexPath.row < self.arrData.count) {
        VcashTxLog *txLog = self.arrData[indexPath.row];
        [cell setTxLog:txLog];
    }
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
