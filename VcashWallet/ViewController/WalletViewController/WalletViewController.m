//
//  WalletViewController.m
//  PoolinWallet
//
//  Created by jia zhou on 2018/7/31.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "WalletViewController.h"
#import "WalletWrapper.h"
#import "SendTransactionViewController.h"
//#import "ReceiveTransactionViewController.h"
#import "WalletCell.h"
#import "VcashTxLog.h"
#import "TransactionDetailViewController.h"
//#import "SettingViewController.h"
#import "HandleSlateViewController.h"
#import "ServerTxManager.h"
#import "LeftMenuView.h"
#import "RefreshStateHeader.h"

static NSString *const identifier = @"WalletCell";

@interface WalletViewController ()<UITableViewDataSource,UITableViewDelegate,LeftMenuViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *viewHeader;

@property (weak, nonatomic) IBOutlet UIButton *btnOpenOrCloseLeftMenu;


@property (weak, nonatomic) IBOutlet UILabel *balanceTotal;

@property (weak, nonatomic) IBOutlet UIView *maskView;


@property (weak, nonatomic) IBOutlet UILabel *balanceConfirmed;

@property (weak, nonatomic) IBOutlet UILabel *balanceUnconfirmed;

@property (weak, nonatomic) IBOutlet UILabel *netName;

@property (weak, nonatomic) IBOutlet UILabel *chainHeight;
@property (weak, nonatomic) IBOutlet UITableView *tableViewContainer;
@property (weak, nonatomic) IBOutlet UITextView *userIdView;

@property (weak, nonatomic) IBOutlet VcashButton *receiveVcashBtn;

@property (weak, nonatomic) IBOutlet VcashButton *sendVcashBtn;

@property (weak, nonatomic) IBOutlet UIView *transactionTitleView;

@property (strong, nonatomic) IBOutlet UIView *footView;


@property (nonatomic, strong) LeftMenuView *leftMenuView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintNaviHeight;

@property (nonatomic, strong) NSArray *arrTransactionList;


@end

@implementation WalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubviews];
    if (!self.enterInRecoverMode){
        [self.tableViewContainer.mj_header beginRefreshing];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMainView) name:kTxLogDataChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMainView) name:kWalletChainHeightChange object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self refreshMainView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [WalletWrapper updateOutputStatusWithComplete:^(BOOL yesOrNo, id data) {
        [self refreshMainView];
    }];
     [[ServerTxManager shareInstance] startWork];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[ServerTxManager shareInstance] stopWork];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)initSubviews{
    if (@available(iOS 11.0, *)) {
        self.tableViewContainer.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        
    } else {
        if([UIViewController instancesRespondToSelector:@selector(edgesForExtendedLayout)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.constraintNaviHeight.constant = kTopHeight;
    [self.leftMenuView addInView];
    
    self.maskView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    [AppHelper addLineWithParentView:self.transactionTitleView];
    
    UIView *tableViewHeader = [[UIView alloc] init];
    tableViewHeader.frame = CGRectMake(0, 0, ScreenWidth, 273);
    [tableViewHeader addSubview:self.viewHeader];
    [self.viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(tableViewHeader);
    }];
    self.tableViewContainer.tableHeaderView = tableViewHeader;
    self.tableViewContainer.dataSource = self;
    self.tableViewContainer.delegate = self;
    [self.tableViewContainer registerNib:[UINib nibWithNibName:NSStringFromClass([WalletCell class]) bundle:nil] forCellReuseIdentifier:identifier];
    self.tableViewContainer.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableViewContainer.mj_header = [RefreshStateHeader headerWithRefreshingBlock:^{
        [self refreshWalletStatus];
    }];
    
    ViewRadius(self.receiveVcashBtn, 4.0);
    ViewRadius(self.sendVcashBtn, 4.0);
    
    [self.receiveVcashBtn setBackgroundImage:[UIImage imageWithColor:CGreenColor] forState:UIControlStateNormal];
    [self.receiveVcashBtn setBackgroundImage:[UIImage imageWithColor:CGreenHighlightedColor] forState:UIControlStateHighlighted];
    
    [self.sendVcashBtn setBackgroundImage:[UIImage imageWithColor:COrangeColor] forState:UIControlStateNormal];
    [self.sendVcashBtn setBackgroundImage:[UIImage imageWithColor:COrangeHighlightedColor] forState:UIControlStateHighlighted];
    
    
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    UIRectCorner corner = UIRectCornerTopLeft | UIRectCornerTopRight;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.transactionTitleView.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(6, 6)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.transactionTitleView.bounds;
    maskLayer.path = bezierPath.CGPath;
    self.transactionTitleView.layer.mask = maskLayer;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)refreshWalletStatus{
    [WalletWrapper updateOutputStatusWithComplete:^(BOOL yesOrNo, id data) {
        [self.tableViewContainer.mj_header endRefreshing];
        [self refreshMainView];
    }];
    [[ServerTxManager shareInstance] fetchTxStatus:YES];
}

-(void)refreshMainView{
    self.userIdView.text = [WalletWrapper getWalletUserId];
    WalletBalanceInfo* info = [WalletWrapper getWalletBalanceInfo];
    NSString *balance = @([WalletWrapper nanoToVcash:info.total]).p09fString;
    NSString *confirm = @([WalletWrapper nanoToVcash:info.spendable]).p09fString;
    NSString *unconfirm =  @([WalletWrapper nanoToVcash:info.unconfirmed]).p09fString;
    self.balanceTotal.text = [NSString stringWithFormat:@"%@ V", balance];
    
    self.balanceConfirmed.text = [NSString stringWithFormat:@"%@",confirm];
    
    self.balanceUnconfirmed.text = [NSString stringWithFormat:@"%@",unconfirm];
    
    self.chainHeight.text = [NSString stringWithFormat:@"Height:%@", @([WalletWrapper getCurChainHeight])];
    
#ifdef isInTestNet
    self.netName.text = @"Floonet";
    self.netName.textColor = [UIColor redColor];
#else
    self.netName.text = @"MainNet";
    self.netName.textColor = [UIColor redColor];
#endif
    
    NSArray *arrTransaction = [WalletWrapper getTransationArr];
    self.arrTransactionList = [arrTransaction sortedArrayUsingComparator:^NSComparisonResult(VcashTxLog *obj1, VcashTxLog *obj2) {
        return [@(obj2.create_time) compare:@(obj1.create_time)];
    }];

    self.tableViewContainer.tableFooterView = self.arrTransactionList.count > 0 ? nil : self.footView;
    [self.tableViewContainer reloadData];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrTransactionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WalletCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (indexPath.row < self.arrTransactionList.count) {
        VcashTxLog *model = self.arrTransactionList[indexPath.row];
        [cell setTxLog:model];
    }
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    VcashTxLog *model = self.arrTransactionList[indexPath.row];
    if (model.tx_type == TxSentCancelled || model.tx_type == TxReceivedCancelled) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
     VcashTxLog *model = self.arrTransactionList[indexPath.row];
    if(editingStyle == UITableViewCellEditingStyleDelete){
       BOOL result = [WalletWrapper deleteTxByTxid:model.tx_slate_id];
        if (!result) {
            DDLogError(@"delete canceled transaction failed");
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 73;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.arrTransactionList.count) {
        VcashTxLog *txLog = self.arrTransactionList[indexPath.row];
        TransactionDetailViewController* transcationDetailVc = [TransactionDetailViewController new];
        transcationDetailVc.txLog = txLog;
        [self.navigationController pushViewController:transcationDetailVc animated:YES];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - LeftMenuViewDelegate

- (void)isHaveHidden:(BOOL)hidden{
    self.btnOpenOrCloseLeftMenu.selected = !hidden;
}

- (void)panLeftMenu:(UIPanGestureRecognizer *)pan{
    CGPoint offSet = [pan translationInView:pan.view];
    CGPoint center = self.leftMenuView.center;
    if (self.leftMenuView.origin.x >= 0 && offSet.x > 0) {
        CGRect fra = self.leftMenuView.frame;
        fra.origin.x = 0;
        self.leftMenuView.frame = fra;
    }else{
        center.x = center.x + offSet.x;
        self.leftMenuView.center = center;
    }
    BOOL isLeft = NO;
    CGPoint velocity = [pan velocityInView:pan.view];
    if (velocity.x < 0) {
        isLeft = YES;
    }
    
    [pan setTranslation:CGPointZero inView:pan.view];
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (!isLeft) {
            if (self.leftMenuView.frame.origin.x >= (- ScreenWidth * 3 /4.0 + 80)) {
                [self.leftMenuView showAnimation];
            }else{
                [self.leftMenuView hiddenAnimation];
            }
        }else{
            [self.leftMenuView hiddenAnimation];
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickedOpenOrCloseLeftMenuView:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self.leftMenuView showAnimation];
    }else{
        [self.leftMenuView hiddenAnimation];
    }
}

- (IBAction)clickSend:(id)sender {
    [self.navigationController pushViewController:[SendTransactionViewController new]  animated:YES];
}

- (IBAction)clickReceive:(id)sender {
    [self.navigationController pushViewController:[HandleSlateViewController new]  animated:YES];
}

#pragma mark - Lazy
- (LeftMenuView *)leftMenuView{
    if (!_leftMenuView) {
        _leftMenuView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LeftMenuView class]) owner:nil options:nil] firstObject];
        _leftMenuView.delegate = self;
    }
    return _leftMenuView;
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