//
//  TokenInfoListViewController.m
//  VcashWallet
//
//  Created by jia zhou on 2020/1/14.
//  Copyright © 2020年 blockin. All rights reserved.
//

#import "TokenInfoListViewController.h"
#import "TokenSwitchCell.h"
#import "WalletWrapper.h"

static NSString *const identifier = @"TokenSwitchCell";

@interface TokenInfoListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TokenInfoListViewController
{
    NSArray* allTokens;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Token List";
    [self initSubviews];
    
    allTokens = [WalletWrapper getAllTokens];
    [self.tableView reloadData];
    // Do any additional setup after loading the view from its nib.
}

- (void)initSubviews{
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
        if([UIViewController instancesRespondToSelector:@selector(edgesForExtendedLayout)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TokenSwitchCell class]) bundle:nil] forCellReuseIdentifier:identifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [allTokens count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TokenSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (indexPath.row < allTokens.count) {
        NSString *tokenType = allTokens[indexPath.row];
        cell.tokenType = tokenType;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
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
