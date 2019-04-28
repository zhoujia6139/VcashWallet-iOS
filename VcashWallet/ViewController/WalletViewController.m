//
//  WalletViewController.m
//  PoolinWallet
//
//  Created by jia zhou on 2018/7/31.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "WalletViewController.h"
#import "WalletWrapper.h"
//#import "SendTransactionViewController.h"
//#import "ReceiveTransactionViewController.h"
#import "WalletCell.h"
#import "VcashTxLog.h"
//#import "TransactionDetailViewController.h"
//#import "SettingViewController.h"

static NSString *const identifier = @"WalletCell";

@interface WalletViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *balanceTotal;

@property (weak, nonatomic) IBOutlet UILabel *balanceConfirmed;

@property (weak, nonatomic) IBOutlet UILabel *balanceUnconfirmed;

@property (weak, nonatomic) IBOutlet UILabel *netName;

@property (weak, nonatomic) IBOutlet UITableView *tableViewContainer;

@property (nonatomic, strong) NSArray *arrTransactionList;

@end

@implementation WalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    self.tableViewContainer.dataSource = self;
    self.tableViewContainer.delegate = self;
    [self.tableViewContainer registerNib:[UINib nibWithNibName:NSStringFromClass([WalletCell class]) bundle:nil] forCellReuseIdentifier:identifier];
//    //[self request];
//    self.tableViewContainer.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
//        [self request];
//    }];
//    [self.tableViewContainer.mj_header beginRefreshing];
    if (self.enterInRecoverMode){
        [WalletWrapper checkWalletUtxoWithComplete:^(BOOL yesOrNo, id ret) {
            if (yesOrNo){
                self.arrTransactionList = ret;
                [self.tableViewContainer reloadData];
            }
        }];
    }
    else{
        self.arrTransactionList = [WalletWrapper getTransationArr];
        [self.tableViewContainer reloadData];
    }
    
    [self refreshMainView];
}

-(void)refreshMainView{
    WalletBalanceInfo* info = [WalletWrapper getWalletBalanceInfo];
    self.balanceTotal.text = @([WalletWrapper nanoToVcash:info.total]).p9fString;
    
    self.balanceConfirmed.text = [NSString stringWithFormat:@"Available %@", @([WalletWrapper nanoToVcash:info.spendable]).p9fString];
    
    self.balanceUnconfirmed.text = [NSString stringWithFormat:@"Uncomfirmed %@", @([WalletWrapper nanoToVcash:info.unconfirmed]).p9fString];;
    
#ifdef isInTestNet
    self.netName.text = @"Floonet";
    self.netName.textColor = [UIColor redColor];
#else
    self.netName.text = @"MainNet";
    self.netName.textColor = [UIColor redColor];
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrTransactionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WalletCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (indexPath.row < self.arrTransactionList.count) {
        VcashTxLog *model = self.arrTransactionList[indexPath.row];
        cell.txLog = model;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 73;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row < self.arrTransactionList.count) {
//        TransactionRecordModel *model = self.arrTransactionList[indexPath.row];
//        TransactionDetailViewController* vc = [TransactionDetailViewController new];
//        vc.transactionData = model;
//        [self.navigationController pushViewController:vc animated:YES];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//- (IBAction)clickSend:(id)sender {
//    [self.navigationController pushViewController:[SendTransactionViewController new]  animated:YES];
//}
//
//- (IBAction)clickReceive:(id)sender {
//    [self.navigationController pushViewController:[ReceiveTransactionViewController new]  animated:YES];
//}
//
//- (IBAction)clickSet:(id)sender {
//    [self.navigationController pushViewController:[SettingViewController new]  animated:YES];
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
