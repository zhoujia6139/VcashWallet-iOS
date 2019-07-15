//
//  AddressBookViewController.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/7/12.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "AddressBookViewController.h"
#import "AddressBookCell.h"
#import "AddressBookManager.h"
#import "AddAddressBookViewController.h"

static NSString *const identifier = @"AddressBookCell";

@interface AddressBookViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableViewContainer;


@property (weak, nonatomic) IBOutlet UIView *viewNoData;

@property (nonatomic, strong) NSMutableArray *arrData;

@end

@implementation AddressBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = [LanguageService contentForKey:@"addressBookTitle"];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [rightBtn setTitle:@"add" forState:UIControlStateNormal];
    rightBtn.frame = CGRectMake(0, 0, 40, 40);
    [rightBtn addTarget:self action:@selector(pushAddAddressBookVc) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    [self.tableViewContainer registerNib:[UINib nibWithNibName:NSStringFromClass([AddressBookCell class]) bundle:nil] forCellReuseIdentifier:identifier];
    self.tableViewContainer.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    if (!self.fromSendTxVc) {
        self.isShowLeftBack = NO;
        self.isShowLeftMeue = YES;
    }
    NSArray *arrAddressBook = [[AddressBookManager shareInstance] getAddressBook];
    if (arrAddressBook) {
        _arrData = [NSMutableArray arrayWithArray:arrAddressBook];
    }
    self.viewNoData.hidden = (self.arrData.count > 0) ? YES : NO;
    [self.tableViewContainer reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AddressBookCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (indexPath.row < self.arrData.count) {
        AddressBookModel *model = self.arrData[indexPath.row];
        cell.model = model;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AddressBookModel *model = self.arrData[indexPath.row];
    if (self.fromSendTxVc) {
        if ([self.delegate respondsToSelector:@selector(selectedAddressBook:)]) {
            [self.delegate selectedAddressBook:model];
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
    }
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertVc addAction:[UIAlertAction actionWithTitle:[LanguageService contentForKey:@"copy"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIPasteboard generalPasteboard] setString:model.address];
        [self.view makeToast:[LanguageService contentForKey:@"copiedToClipboard"]];
    }]];
    [alertVc addAction:[UIAlertAction actionWithTitle:[LanguageService contentForKey:@"Delete"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BOOL deleteSuc = [[AddressBookManager shareInstance] deleteAddressBookModel:model];
        if (deleteSuc) {
            [self.arrData removeObject:model];
            self.viewNoData.hidden = (self.arrData.count > 0) ? YES : NO;
            [self.tableViewContainer reloadData];
        }
    }]];
    [alertVc addAction:[UIAlertAction actionWithTitle:[LanguageService contentForKey:@"cancel"] style:UIAlertActionStyleCancel handler:nil]];
    [self.navigationController presentViewController:alertVc animated:YES completion:nil];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSArray <UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:[LanguageService contentForKey:@"Delete"] handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
         AddressBookModel *model = self.arrData[indexPath.row];
         BOOL deleteSuc = [[AddressBookManager shareInstance] deleteAddressBookModel:model];
         if (deleteSuc) {
             [self.arrData removeObject:model];
             self.viewNoData.hidden = (self.arrData.count > 0) ? YES : NO;
             [self.tableViewContainer reloadData];
         }
    }];
    return @[deleAction];
}

- (void)pushAddAddressBookVc{
    AddAddressBookViewController *addAddressVc = [[AddAddressBookViewController alloc] init];
    [self.navigationController pushViewController:addAddressVc animated:YES];
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
