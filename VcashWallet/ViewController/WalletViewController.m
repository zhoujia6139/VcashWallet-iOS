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
#import "NSNumber+Utils.h"
//#import "WalletCell.h"
//#import "TransactionRecordModel.h"
//#import "TransactionDetailViewController.h"
//#import "SettingViewController.h"

static NSString *const identifier = @"WalletCell";

@interface WalletViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *labelTotalBtc;

@property (weak, nonatomic) IBOutlet UILabel *labelAddress;

@property (weak, nonatomic) IBOutlet UITableView *tableViewContainer;


@property (nonatomic, strong) NSString *address;

@property (nonatomic, strong) NSMutableArray *arrTransactionList;

@property (nonatomic, strong) NSMutableArray *arrHashIds;

@end

@implementation WalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    NSString* json = self.labelAddress.text;
    VcashSlate* slate = [VcashSlate modelWithJSON:json];
    BOOL yesOrNo = [WalletWrapper finalizeTransaction:slate];
    NSLog(@"");
    // Do any additional setup after loading the view from its nib.
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
//    self.address = [WalletWrapper getCurAccountAddress];
//    self.labelAddress.text = self.address;
//    [_tableViewContainer registerNib:[UINib nibWithNibName:NSStringFromClass([WalletCell class]) bundle:nil] forCellReuseIdentifier:identifier];
//    //[self request];
//    self.tableViewContainer.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
//        [self request];
//    }];
//    [self.tableViewContainer.mj_header beginRefreshing];
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
//    WalletCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
//    if (indexPath.row < self.arrTransactionList.count) {
//        TransactionRecordModel *model = self.arrTransactionList[indexPath.row];
//        cell.transactionrecordModel = model;
//    }
    return nil;
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

- (NSMutableArray *)arrTransactionList{
    if (!_arrTransactionList) {
        _arrTransactionList = [NSMutableArray array];
    }
    return _arrTransactionList;
}

- (NSMutableArray *)arrHashIds{
    if (!_arrHashIds) {
        _arrHashIds = [NSMutableArray array];
    }
    return _arrHashIds;
}

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
