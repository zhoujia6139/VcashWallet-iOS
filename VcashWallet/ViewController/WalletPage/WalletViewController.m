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
#import "WalletCell.h"
#import "VcashTxLog.h"
#import "TransactionDetailViewController.h"
#import "HandleSlateViewController.h"
#import "ServerTxManager.h"
#import "LeftMenuView.h"
#import "RefreshStateHeader.h"
#import "ServerTransactionBlackManager.h"
#import "LeftMenuManager.h"
#import "WalletPageSectionView.h"


static NSString *const identifierSection = @"WalletPageSectionView";

static NSString *const identifier = @"WalletCell";

#define ServerTxs @"ServerTxs"
#define TxLog @"TxLog"

#define txOngoing @"txOngoing"
#define txComplete @"txComplete"

@interface WalletViewController ()<UITableViewDataSource,UITableViewDelegate,LeftMenuViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *tokenIcon;

@property (weak, nonatomic) IBOutlet UILabel *tokenName;

@property (weak, nonatomic) IBOutlet UILabel *tokenFullName;

@property (weak, nonatomic) IBOutlet UIImageView *headerBg;

@property (strong, nonatomic) IBOutlet UIView *viewHeader;

@property (weak, nonatomic) IBOutlet UILabel *balanceTotal;

@property (weak, nonatomic) IBOutlet UIView *maskView;


@property (weak, nonatomic) IBOutlet UILabel *balanceConfirmed;

@property (weak, nonatomic) IBOutlet UILabel *balanceUnconfirmed;

@property (weak, nonatomic) IBOutlet UILabel *netName;

@property (weak, nonatomic) IBOutlet UILabel *chainHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintChainHeightWidth;

@property (weak, nonatomic) IBOutlet UITableView *tableViewContainer;
@property (weak, nonatomic) IBOutlet UITextView *userIdView;

@property (weak, nonatomic) IBOutlet VcashButton *receiveVcashBtn;

@property (weak, nonatomic) IBOutlet VcashButton *sendVcashBtn;


@property (strong, nonatomic) IBOutlet UIView *footView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintNaviHeight;

@property (nonatomic, strong) NSMutableArray *arrSections;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintViewBottomHeight;

@property (nonatomic, strong) NSMutableArray *arrOngoing;

@property (nonatomic, strong) NSMutableArray *arrComplete;

@property (weak, nonatomic) IBOutlet UIView *viewNavi;

@end

@implementation WalletViewController{
    BOOL first;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    first = YES;
    [self initSubviews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMainView) name:kWalletChainHeightChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMainView) name:kServerTxChange object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    if (!first) {
        [self refreshOutputStatus];
    }else{
        first = NO;
    }
   
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[ServerTxManager shareInstance] hiddenMsgNotificationView];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initSubviews{
    [AppHelper addLineWithParentView:self.viewNavi];
    if (@available(iOS 11.0, *)) {
        self.tableViewContainer.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
        if([UIViewController instancesRespondToSelector:@selector(edgesForExtendedLayout)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
    self.constraintNaviHeight.constant = kTopHeight;
    self.constraintChainHeightWidth.constant = ScreenWidth - 210;
    [[[LeftMenuManager shareInstance] leftMenuView] addInView];
    
    self.maskView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    
    UIView *tableViewHeader = [[UIView alloc] init];
    tableViewHeader.frame = CGRectMake(0, 0, ScreenWidth, 201);
    [tableViewHeader addSubview:self.viewHeader];
    [self.viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(tableViewHeader);
    }];
    self.tableViewContainer.tableHeaderView = tableViewHeader;
    self.tableViewContainer.dataSource = self;
    self.tableViewContainer.delegate = self;
    [self.tableViewContainer registerClass:[WalletPageSectionView class] forHeaderFooterViewReuseIdentifier:identifierSection];
    [self.tableViewContainer registerNib:[UINib nibWithNibName:NSStringFromClass([WalletCell class]) bundle:nil] forCellReuseIdentifier:identifier];
    self.tableViewContainer.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableViewContainer.estimatedSectionHeaderHeight = 0;
    self.tableViewContainer.estimatedSectionFooterHeight = 0;
    self.tableViewContainer.estimatedRowHeight = 0;
    self.tableViewContainer.sectionHeaderHeight = 0;
    self.tableViewContainer.sectionFooterHeight = 0;
    self.tableViewContainer.mj_header = [RefreshStateHeader headerWithRefreshingBlock:^{
        [self refreshWalletStatus];
    }];
    
    self.constraintViewBottomHeight.constant = 59 + (iPhoneX ? 34 : 0);
    ViewRadius(self.receiveVcashBtn, 4.0);
    ViewRadius(self.sendVcashBtn, 4.0);
    
    [self.receiveVcashBtn setBackgroundImage:[UIImage imageWithColor:CGreenColor] forState:UIControlStateNormal];
    [self.receiveVcashBtn setBackgroundImage:[UIImage imageWithColor:CGreenHighlightedColor] forState:UIControlStateHighlighted];
    
    [self.sendVcashBtn setBackgroundImage:[UIImage imageWithColor:COrangeColor] forState:UIControlStateNormal];
    [self.sendVcashBtn setBackgroundImage:[UIImage imageWithColor:COrangeHighlightedColor] forState:UIControlStateHighlighted];
    [self refreshMainView];
}

-(void)refreshWalletStatus{
    [WalletWrapper updateTxStatus];
    __weak typeof(self) weakSelf = self;
    [[ServerTxManager shareInstance] fetchTxStatus:YES WithComplete:^(BOOL yesOrNo, id _Nullable result) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!yesOrNo) {
            [strongSelf.view makeToast:[LanguageService contentForKey:@"networkRequestFailed"]];
        }
        [strongSelf refreshOutputStatus];
    }];
}

-(void)refreshOutputStatus{
    if (self.tokenType) {
        [WalletWrapper updateTokenOutputStatusWithComplete:^(BOOL yesOrNo, id data) {
            [self.tableViewContainer.mj_header endRefreshing];
            [self refreshMainView];
        }];
    }
    else {
        [WalletWrapper updateOutputStatusWithComplete:^(BOOL yesOrNo, id data) {
            [self.tableViewContainer.mj_header endRefreshing];
            [self refreshMainView];
        }];
    }
}

-(void)refreshMainView{
    self.userIdView.text = [WalletWrapper getWalletUserId];
    WalletBalanceInfo* info;
    NSArray *arrTransaction;
    if (!self.tokenType) {
        self.tokenIcon.image = [UIImage imageNamed:@"vc_icon.png"];
        self.headerBg.image = [UIImage imageNamed:@"vc_icon.png"];
        self.tokenName.text = @"VCash";
        self.tokenFullName.text = @"";
        
        info = [WalletWrapper getWalletBalanceInfo];
        arrTransaction = [WalletWrapper getTransationArr];
    } else {
        VcashTokenInfo* tokenInfo = [WalletWrapper getTokenInfo:self.tokenType];
//        NSURL *url = [NSURL URLWithString: tokenInfo.IconData];
//        NSData *data = [NSData dataWithContentsOfURL: url];
//        UIImage *decodedImage = [UIImage imageWithData:data];
//        if (decodedImage) {
//            self.tokenIcon.image = decodedImage;
//            self.headerBg.image = decodedImage;
//        }
        self.tokenName.text = tokenInfo.Name;
        self.tokenFullName.text = tokenInfo.FullName;
        
        info = [WalletWrapper getWalletTokenBalanceInfo:self.tokenType];
        arrTransaction = [WalletWrapper getTokenTxArr:self.tokenType];
    }
    NSString *balance = @([WalletWrapper nanoToVcash:info.total]).p09fString;
    NSString *confirm = @([WalletWrapper nanoToVcash:info.spendable]).p09fString;
    NSString *unconfirm =  @([WalletWrapper nanoToVcash:info.unconfirmed]).p09fString;
    self.balanceTotal.font = [UIFont robotoRegularWithSize:32];
    self.balanceTotal.text = balance;
    
    self.balanceConfirmed.font = [UIFont robotoRegularWithSize:14];
    self.balanceConfirmed.text = [NSString stringWithFormat:@"%@",confirm];
    
    self.balanceUnconfirmed.font = [UIFont robotoRegularWithSize:14];
    self.balanceUnconfirmed.text = [NSString stringWithFormat:@"%@",unconfirm];
    
    self.chainHeight.text = [NSString stringWithFormat:@"Height:%@", @([WalletWrapper getCurChainHeight])];
    
    NSArray *arrSortTxs = [NSArray array];
    if (arrTransaction) {
        NSMutableArray *mutableArrTransaction = [NSMutableArray arrayWithArray:arrTransaction];
        NSInteger count = arrTransaction.count;
        NSMutableArray *deleteTransaction = [NSMutableArray array];
        for (NSInteger i = 0; i < count; i++) {
            BaseVcashTxLog *tx_log = arrTransaction[i];
            ServerTransaction *serverTx = [[ServerTxManager shareInstance] getServerTxByTx_id:tx_log.tx_slate_id];
            if (serverTx) {
                [deleteTransaction addObject:tx_log];
            }
        }
        [mutableArrTransaction removeObjectsInArray:deleteTransaction];
        arrSortTxs = [mutableArrTransaction sortedArrayUsingComparator:^NSComparisonResult(BaseVcashTxLog *obj1, BaseVcashTxLog *obj2) {
            return [@(obj2.create_time) compare:@(obj1.create_time)];
        }];
    }
    
    NSArray *arrServerTransactins = [[ServerTxManager shareInstance] allServerTransactions];
    [self.arrOngoing removeAllObjects];
    [self.arrComplete removeAllObjects];
    if (arrServerTransactins.count > 0) {
        [self.arrOngoing addObjectsFromArray:arrServerTransactins];
    }
    for (NSInteger i = 0; i < arrSortTxs.count; i++) {
        BaseVcashTxLog *txLog = arrSortTxs[i];
        if ([txLog isKindOfClass:[VcashTxLog class]]) {
            VcashTxLog* vcLog = (VcashTxLog*)txLog;
            if (txLog.confirm_state == NetConfirmed || vcLog.tx_type == TxSentCancelled || vcLog.tx_type == TxReceivedCancelled) {
                [self.arrComplete addObject:txLog];
            }else{
                [self.arrOngoing addObject:txLog];
            }
        } else {
            VcashTokenTxLog* tokenLog = (VcashTokenTxLog*)txLog;
            if (txLog.confirm_state == NetConfirmed || tokenLog.tx_type == TxSentCancelled || tokenLog.tx_type == TxReceivedCancelled) {
                [self.arrComplete addObject:txLog];
            }else{
                [self.arrOngoing addObject:txLog];
            }
        }
    }
  
    [self.arrSections removeAllObjects];
    if (self.arrOngoing.count > 0) {
        [self.arrSections addObject:txOngoing];
    }
    if (self.arrComplete.count > 0) {
        [self.arrSections addObject:txComplete];
    }
    self.tableViewContainer.tableFooterView = ((self.arrOngoing.count   +  self.arrComplete.count) > 0 )? nil : self.footView;
    if (self.arrSections.count == 0) {
        [self.arrSections addObject:txComplete];
    }
    [self.tableViewContainer reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.arrSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *title = self.arrSections[section];
    if ([title isEqualToString:txOngoing]) {
        return self.arrOngoing.count;
    }
    return self.arrComplete.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WalletCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    NSString *title = self.arrSections[indexPath.section];
    if ([title isEqualToString:txOngoing]) {
        if (indexPath.row < self.arrOngoing.count) {
            id tx = self.arrOngoing[indexPath.row];
            if ([tx isKindOfClass:[ServerTransaction class]]) {
                [cell setServerTransaction:tx];
            }else{
                [cell setTxLog:tx];
            }
        }
        return cell;
    }
    if (indexPath.row < self.arrComplete.count) {
        VcashTxLog *model = self.arrComplete[indexPath.row];
        [cell setTxLog:model];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *title = self.arrSections[section];
    WalletPageSectionView *sectionView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifierSection];
    if (!sectionView) {
        sectionView = [[WalletPageSectionView alloc] initWithReuseIdentifier:identifierSection];
    }
    if ([title isEqualToString:txOngoing]) {
        sectionView.title = [LanguageService  contentForKey:@"ongoingTx"];
    }else{
        sectionView.title = [LanguageService contentForKey:@"completedTx"];
    }
    return sectionView;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = self.arrSections[indexPath.section];
    if ([title isEqualToString:txOngoing]) {
        id tx = self.arrOngoing[indexPath.row];
        if ([tx isKindOfClass:[ServerTransaction class]]) {
            ServerTransaction *serverTx = (ServerTransaction *)tx;
            if (serverTx.status == TxCanceled) {
                return YES;
            }
        }else{
             VcashTxLog *model = (VcashTxLog *)tx;
            if (model.tx_type == TxReceived && !model.parter_id && model.signed_slate_msg) {
                if (model.confirm_state != NetConfirmed) {
                    return YES;
                }
            }
        }
        return NO;
    }
    VcashTxLog *model = self.arrComplete[indexPath.row];
    if (model.tx_type == TxSentCancelled || model.tx_type == TxReceivedCancelled) {
        return YES;
    }
    return NO;
}

- (NSArray <UITableViewRowAction *>*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:[LanguageService contentForKey:@"Delete"] handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSString *title = self.arrSections[indexPath.section];
        if ([title isEqualToString:txOngoing]) {
            id tx = self.arrOngoing[indexPath.row];
            if ([tx isKindOfClass:[ServerTransaction class]]) {
                ServerTransaction *serverTx = (ServerTransaction *)tx;
                BOOL result = [WalletWrapper deleteTxByTxid:serverTx.tx_id];
                if (!result) {
                    DDLogError(@"delete canceled transaction failed");
                }else{
                    [self refreshMainView];
                }
            }else{
                VcashTxLog *model = (VcashTxLog *)tx;
                if (model.tx_type == TxReceived && !model.parter_id && model.signed_slate_msg) {
                    if (model.confirm_state != NetConfirmed) {
                        UIAlertController *alterVc = [UIAlertController alertControllerWithTitle:[LanguageService contentForKey:@"deleteTxTitle"] message:[LanguageService contentForKey:@"deleteTxMsg"] preferredStyle:UIAlertControllerStyleAlert];
                        [alterVc addAction:[UIAlertAction actionWithTitle:[LanguageService contentForKey:@"cancel"] style:UIAlertActionStyleDefault handler:nil]];
                        [alterVc addAction:[UIAlertAction actionWithTitle:[LanguageService contentForKey:@"ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [MBHudHelper startWorkProcessWithTextTips:[LanguageService contentForKey:@"deleting"]];
                            BOOL cancelSuc = [WalletWrapper cancelTransaction:model.tx_slate_id];
                            if (!cancelSuc) {
                                [MBHudHelper
                                 endWorkProcessWithSuc:NO andTextTips:[LanguageService contentForKey:@"deleteFailed"]];
                            }else{
                                BOOL result = [WalletWrapper deleteTxByTxid:model.tx_slate_id];
                                NSString *tips = result ? [LanguageService contentForKey:@"deleteSuc"] :[LanguageService contentForKey:@"deleteFailed"];
                                [MBHudHelper
                                 endWorkProcessWithSuc:result andTextTips:tips];
                                if(result){
                                    [self refreshMainView];
                                }else{
                                    DDLogError(@"delete tx failed");
                                }
                            }
                        }]];
                        [self.navigationController presentViewController:alterVc animated:YES completion:nil];
                    }
                }
                   
                
            }
            return;
        }
        VcashTxLog *model = self.arrComplete[indexPath.row];
        BOOL result = [WalletWrapper deleteTxByTxid:model.tx_slate_id];
        if (!result) {
            DDLogError(@"delete canceled transaction failed");
        }else{
            [self refreshMainView];
        }
    }];
    return @[deleteRowAction];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 73;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     NSString *title = self.arrSections[indexPath.section];
     if ([title isEqualToString:txOngoing]) {
         if (indexPath.row < self.arrOngoing.count) {
             id tx = self.arrOngoing[indexPath.row];
             if ([tx isKindOfClass:[ServerTransaction class]]) {
                 ServerTransaction *serverTx = (ServerTransaction *)tx;
                 [self pushTransactionDetailVcWithTxLog:nil serverTx:serverTx];
             }else{
                 VcashTxLog *txLog =  (VcashTxLog *)tx;
                 [self pushTransactionDetailVcWithTxLog:txLog serverTx:nil];
             }
         }
         return;
     }
    if (indexPath.row < self.arrComplete.count) {
        VcashTxLog *txLog = self.arrComplete[indexPath.row];
        [self pushTransactionDetailVcWithTxLog:txLog serverTx:nil];
    }
}

- (void)pushTransactionDetailVcWithTxLog:(VcashTxLog *)txLog serverTx:(ServerTransaction *)serverTx{
    if (serverTx) {
        [[ServerTransactionBlackManager shareInstance] writeBlackServerTransaction:serverTx];
    }
    TransactionDetailViewController* transcationDetailVc = [TransactionDetailViewController new];
    transcationDetailVc.serverTx = serverTx;
    transcationDetailVc.txLog = txLog;
    [self.navigationController pushViewController:transcationDetailVc animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickedOpenLeftMenuView:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickSend:(id)sender {
    SendTransactionViewController* vc = [SendTransactionViewController new];
    vc.tokenType = self.tokenType;
    [self.navigationController pushViewController:vc  animated:YES];
}

- (IBAction)clickReceive:(id)sender {
    [self.navigationController pushViewController:[HandleSlateViewController new]  animated:YES];
}


- (NSMutableArray *)arrSections{
    if (!_arrSections) {
        _arrSections = [NSMutableArray array];
    }
    return _arrSections;
}

- (NSMutableArray *)arrOngoing{
    if (!_arrOngoing) {
        _arrOngoing = [NSMutableArray array];
    }
    return _arrOngoing;
}


- (NSMutableArray *)arrComplete{
    if (!_arrComplete) {
        _arrComplete = [NSMutableArray array];
    }
    return _arrComplete;
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
