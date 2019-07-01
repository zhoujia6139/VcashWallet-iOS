//
//  ReceiveTransactionFileViewController.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/6/21.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "ReceiveTransactionFileViewController.h"
#import "ReceiverSignTransactionFileViewController.h"
#import "TransactionDetailView.h"
#import "TransactionFileSignedRecordViewController.h"

@interface ReceiveTransactionFileViewController ()<UITextViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextView *fileContentTextView;


@end

@implementation ReceiveTransactionFileViewController{
    UIButton *readTxDetailBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.fileContentTextView becomeFirstResponder];
}

- (void)configView{
    self.title = [LanguageService contentForKey:@"receiveTransactionFile"];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitleColor:[UIColor colorWithHexString:@""] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor colorWithHexString:@"#FF9502"] forState:UIControlStateNormal];
    [rightBtn setTitle:[LanguageService contentForKey:@"record"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(pushRecordVc) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
    _scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_scrollView];
    
    UIView *promptView = [[UIView alloc] init];
    promptView.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
    [_scrollView addSubview:promptView];
    ViewRadius(promptView, 4.0);
    
    [promptView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView).offset(12);
        make.left.equalTo(self.scrollView).offset(12);
        make.right.equalTo(self.scrollView).offset(-12);
        make.width.mas_equalTo(ScreenWidth - 24);
    }];
    
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.numberOfLines = 0;
    promptLabel.text = [LanguageService contentForKey:@"receiveTransactionFilePrompt"];
    promptLabel.font = [UIFont systemFontOfSize:14];
    promptLabel.textColor = [UIColor colorWithHexString:@"#1F1F1F"];
    [promptView addSubview:promptLabel];
    [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(promptView).offset(16);
        make.left.equalTo(promptView).offset(20);
        make.right.equalTo(promptView).offset(-20);
        make.bottom.equalTo(promptView).offset(-16);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textColor = [UIColor colorWithHexString:@"#1F1F1F"];
    titleLabel.text = [LanguageService contentForKey:@"enterTransactionFileContent"];
    [_scrollView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(promptView.mas_bottom).offset(23);
        make.left.equalTo(self.scrollView).offset(22);
        make.right.equalTo(self.scrollView).offset(-22);
        
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#EEEEEE"];
    [_scrollView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(14);
        make.left.right.equalTo(self.scrollView);
        make.height.mas_equalTo(2);
    }];
    
    _fileContentTextView = [[UITextView alloc] init];
    _fileContentTextView.font = [UIFont systemFontOfSize:14];
    _fileContentTextView.delegate = self;
    [_scrollView addSubview:_fileContentTextView];
    [_fileContentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView.mas_bottom);
        make.left.equalTo(self.scrollView).offset(20);
        make.right.equalTo(self.scrollView);
        make.bottom.equalTo(self.view).offset(-200);
    }];
    
    UIView *bottomlineView = [[UIView alloc] init];
    bottomlineView.backgroundColor = [UIColor colorWithHexString:@"#EEEEEE"];
    [_scrollView addSubview:bottomlineView];
    [bottomlineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fileContentTextView.mas_bottom);
        make.left.right.equalTo(self.scrollView);
        make.height.mas_equalTo(2);
    }];
    
    readTxDetailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    readTxDetailBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [readTxDetailBtn setTitle:[LanguageService contentForKey:@"readTxDetails"] forState:UIControlStateNormal];
    readTxDetailBtn.backgroundColor = COrangeEnableColor;
    readTxDetailBtn.userInteractionEnabled = NO;
    [readTxDetailBtn addTarget:self action:@selector(readTransactionDetail) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:readTxDetailBtn];
    [readTxDetailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.right.offset(-20);
        make.bottom.offset(-40);
        make.height.mas_equalTo(44);
    }];
    ViewRadius(readTxDetailBtn, 4.0);
    
    self.fileContentTextView.textContainerInset = UIEdgeInsetsMake(20, 0, 20, 20);
    
}

- (void)readTransactionDetail{
    //Transaction details
    [WalletWrapper isValidSlateConent:self.fileContentTextView.text withComplete:^(BOOL yesOrNo, id _Nullable data) {
        if (yesOrNo) {
            VcashSlate *slate = (VcashSlate *)data;
            [self showTxDetailViewWithSlate:slate];
        }else{
            [self.view makeToast:data];
        }
    }];
    
}

- (void)getSignTxFileContentWith:(VcashSlate *)slate{
    if (!slate) {
        return;
    }
    [WalletWrapper receiveTransactionBySlate:slate withComplete:^(BOOL yesOrNo, id _Nullable data) {
        if (yesOrNo) {
            ReceiverSignTransactionFileViewController *signTxFileVc = [[ReceiverSignTransactionFileViewController alloc] init];
            VcashTxLog *txLog = [WalletWrapper getTxByTxid:slate.uuid];
            signTxFileVc.txLog = txLog;
            [self.navigationController pushViewController:signTxFileVc animated:YES];
//            self.signTxFileContontTexView.text = data;
        }else{
            [self.view makeToast:data];
        }
    }];
}

- (void)showTxDetailViewWithSlate:(VcashSlate *)slate{
    TransactionDetailView *txDetailView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TransactionDetailView class]) owner:nil options:nil] firstObject];
    txDetailView.slate = slate;
    txDetailView.signCallBack = ^(VcashSlate * _Nonnull slate) {
        [self pushReceiverSignTxFileVcWithSlate:slate];
    };
    [txDetailView show];
}

- (void)pushReceiverSignTxFileVcWithSlate:(VcashSlate *)slate{
    [self getSignTxFileContentWith:slate];
}

- (void)pushRecordVc{
    TransactionFileSignedRecordViewController *txFileSignedRecordVc = [[TransactionFileSignedRecordViewController alloc] init];
    [self.navigationController pushViewController:txFileSignedRecordVc animated:YES];
}


#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length > 0) {
        readTxDetailBtn.backgroundColor = COrangeColor;
        readTxDetailBtn.userInteractionEnabled = YES;
    }else{
        readTxDetailBtn.backgroundColor = COrangeEnableColor;
        readTxDetailBtn.userInteractionEnabled = NO;
    }
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
