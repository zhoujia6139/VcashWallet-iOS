//
//  MainViewController.m
//  VcashWallet
//
//  Created by jia zhou on 2020/1/13.
//  Copyright © 2020年 blockin. All rights reserved.
//

#import "MainViewController.h"
#import "TokenInfoCell.h"
#import "LeftMenuView.h"
#import "LeftMenuManager.h"
#import "WalletWrapper.h"
#import "RefreshStateHeader.h"
#import "WalletViewController.h"
#import "ServerTxManager.h"
#import "TokenInfoListViewController.h"
#import "VerifyPaymentProofViewController.h"

static NSString *const identifier = @"TokenInfoCell";

@interface MainViewController ()<UITableViewDataSource,UITableViewDelegate,LeftMenuViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MainViewController
{
    NSArray* tokenArr;
    BOOL vcRefreshed;
    BOOL tokenRefreshed;
    NSTimeInterval lastFetch;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    lastFetch = 0;
    [self initSubviews];
    [self refreshMainView];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverTxStartWork) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverTxStopWork) name:UIApplicationWillEnterForegroundNotification object:nil];
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
    
    self.title = @"VCash Wallet";
    self.isShowLeftMeue = YES;
    [[[LeftMenuManager shareInstance] leftMenuView] addInView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TokenInfoCell class]) bundle:nil] forCellReuseIdentifier:identifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.tableView.mj_header = [RefreshStateHeader headerWithRefreshingBlock:^{
        [self refreshWalletStatus:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self serverTxStartWork];
    if (!self.enterInRecoverMode){
        [self refreshWalletStatus:NO];
    }
    [self refreshMainView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self serverTxStopWork];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.createNewWallet || self.enterInRecoverMode) {
        [MBHudHelper startWorkProcessWithTextTips:@""];
        [MBHudHelper endWorkProcessWithSuc:YES andTextTips:[LanguageService contentForKey:@"usableWallet"]];
        self.createNewWallet = NO;
        self.enterInRecoverMode = NO;
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma private
-(void)refreshMainView{
    NSMutableArray* arr = [NSMutableArray new];
    [arr addObject:@"VCash"];
    NSArray* tokens = [WalletWrapper getBalancedToken];
    [arr addObjectsFromArray:tokens];
    
    NSArray* addedToken = [WalletWrapper getAddedTokens];
    for (NSString* addedItem in addedToken) {
        if (![arr containsObject:addedItem]) {
            [arr addObject:addedItem];
        }
    }
    tokenArr = [arr copy];
    [self.tableView reloadData];
}

-(void)refreshWalletStatus:(BOOL)force{
    if (force || [[NSDate date] timeIntervalSince1970] - lastFetch  >= 60){
        [WalletWrapper updateTxStatus];
        __weak typeof(self) weakSelf = self;
        [[ServerTxManager shareInstance] fetchTxStatus:YES WithComplete:^(BOOL yesOrNo, id _Nullable result) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!yesOrNo) {
                [strongSelf.view makeToast:[LanguageService contentForKey:@"networkRequestFailed"]];
            }
            strongSelf->vcRefreshed = NO;
            strongSelf->tokenRefreshed = NO;
            [WalletWrapper updateOutputStatusWithComplete:^(BOOL yesOrNo, id data) {
                strongSelf->vcRefreshed = YES;
                [strongSelf checkRefreshEnd];
            }];
            [WalletWrapper updateTokenOutputStatusWithComplete:^(BOOL yesOrNo, id data) {
                strongSelf->tokenRefreshed = YES;
                [strongSelf checkRefreshEnd];
            }];
        }];
    }
}

-(void)checkRefreshEnd{
    if (vcRefreshed && tokenRefreshed) {
        [self.tableView.mj_header endRefreshing];
        [self refreshMainView];
        lastFetch = [[NSDate date] timeIntervalSince1970];
    }
}

- (void)serverTxStartWork{
    if ([WalletWrapper getWalletUserId]) {
        [[ServerTxManager shareInstance] startWork];
    }
}

- (void)serverTxStopWork{
    [[ServerTxManager shareInstance] stopWork];
}

- (IBAction)clickTokenList:(id)sender {
    [self.navigationController pushViewController:[TokenInfoListViewController new] animated:YES];
}


#pragma tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [tokenArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TokenInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (indexPath.row < tokenArr.count) {
        NSString *tokenType = tokenArr[indexPath.row];
        cell.tokenType = tokenType;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < tokenArr.count) {
        NSString *tokenType = tokenArr[indexPath.row];
        WalletViewController* vc = [WalletViewController new];
        if (![tokenType isEqualToString:@"VCash"]) {
            vc.tokenType = tokenType;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)clickVerifyProof:(id)sender {
    VerifyPaymentProofViewController*vc = [VerifyPaymentProofViewController new];
    [self.navigationController pushViewController:vc animated:YES];
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
