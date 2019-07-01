//
//  ReceiverSignTransactionFileViewController.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/6/21.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "ReceiverSignTransactionFileViewController.h"
#import "TransactionFileSignedRecordViewController.h"

@interface ReceiverSignTransactionFileViewController ()

@property (nonatomic, strong) UITextView *signTxFileContontTexView;

@end

@implementation ReceiverSignTransactionFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
//    [self getSignTxFileContent];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.showDone) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        NSMutableArray *arrVcs = [NSMutableArray arrayWithArray:self.navigationController.childViewControllers];
        NSInteger count = arrVcs.count;
        TransactionFileSignedRecordViewController *fileSignedRecordVc = [TransactionFileSignedRecordViewController new];
        [arrVcs insertObject:fileSignedRecordVc atIndex:count - 1];
        self.navigationController.viewControllers = arrVcs;
    }
   
}

- (void)initView{
    self.title = [LanguageService contentForKey:@"receiveTransactionFile"];
    self.view.backgroundColor = [UIColor whiteColor];
    if(self.showDone){
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setTitleColor:[UIColor colorWithHexString:@"#FF9502"] forState:UIControlStateNormal];
        [rightBtn setTitle:[LanguageService contentForKey:@"done"] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        rightBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        self.navigationItem.rightBarButtonItem = barButtonItem;
    }
    
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.font = [UIFont systemFontOfSize:14];
    promptLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    promptLabel.numberOfLines = 0;
    promptLabel.text = [LanguageService contentForKey:@"signTransactionFilePrompt"];
    [self.view addSubview:promptLabel];
    [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(20);
        make.left.offset(27);
        make.right.offset(-27);
    }];
    
    UILabel *signTxFileTitleLabel =  [[UILabel alloc] init];
    signTxFileTitleLabel.font = [UIFont systemFontOfSize:18];
    signTxFileTitleLabel.textColor = [UIColor colorWithHexString:@"#1F1F1F"];
    signTxFileTitleLabel.text = [LanguageService contentForKey:@"signTxFile"];
    [self.view addSubview:signTxFileTitleLabel];
    [signTxFileTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(promptLabel.mas_bottom).offset(31);
        make.left.offset(29);
    }];
    
    UIButton *copyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:copyBtn];
    [copyBtn addTarget:self action:@selector(copyFileContent) forControlEvents:UIControlEventTouchUpInside];
    [copyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-35);
        make.centerY.equalTo(signTxFileTitleLabel);
        make.height.mas_equalTo(40);
    }];
    
    UIImageView *copyImageView = [[UIImageView alloc] init];
    copyImageView.image = [UIImage imageNamed:@"copyorange.png"];
    [copyBtn addSubview:copyImageView];
    [copyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(copyBtn);
        make.centerY.equalTo(copyBtn);
        make.width.height.mas_equalTo(15);
    }];
    
    UILabel *copyLabel = [[UILabel alloc] init];
    copyLabel.font = [UIFont systemFontOfSize:14];
    copyLabel.textColor = [UIColor colorWithHexString:@"#FF9502"];
    copyLabel.text = [LanguageService contentForKey:@"copy"];
    [copyBtn addSubview:copyLabel];
    [copyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(copyImageView.mas_right).offset(6);
        make.centerY.equalTo(copyBtn);
        make.right.equalTo(copyBtn);
    }];
    
    UIView *signTxFileContentView = [[UIView alloc] init];
    signTxFileContentView.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
    [self.view addSubview:signTxFileContentView];
    ViewRadius(signTxFileContentView, 4.0);
    
    [signTxFileContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(copyBtn.mas_bottom);
        make.left.offset(28);
        make.right.offset(-28);
        make.bottom.offset(-288);
    }];
    
    UILabel *txDetailLabel = [[UILabel alloc] init];
    txDetailLabel.font = [UIFont systemFontOfSize:18];
    txDetailLabel.textColor = [UIColor colorWithHexString:@"#1F1F1F"];
    txDetailLabel.text = [LanguageService contentForKey:@"txDetail"];
    [self.view addSubview:txDetailLabel];
    [txDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(signTxFileContentView.mas_bottom).offset(21);
        make.left.offset(28);
    }];
    
    UIView *txDetailContainer = [[UIView alloc] init];
    txDetailContainer.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
    ViewRadius(txDetailContainer, 4.0);
    [self.view addSubview:txDetailContainer];
    
    [txDetailContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(28);
        make.right.offset(-28);
        make.top.equalTo(txDetailLabel.mas_bottom).offset(10);
    }];
    
    UIView *priTxDetailSubview = nil;
    for (NSInteger i = 0; i < 4; i++) {
        UIView *txDetailContainerSubView = [[UIView alloc] init];
        txDetailContainerSubView.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
        [txDetailContainer addSubview:txDetailContainerSubView];
        if (!priTxDetailSubview) {
            [txDetailContainerSubView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(txDetailContainer);
                make.top.equalTo(txDetailContainer).offset(15);
            }];
        }else{
            [txDetailContainerSubView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(txDetailContainer);
                make.top.equalTo(priTxDetailSubview.mas_bottom).offset(20);
                if (i == 3) {
                  make.bottom.equalTo(txDetailContainer).offset(-15);
                }
            }];
        }
        UILabel *txTitleLabel = [[UILabel alloc] init];
        txTitleLabel.font = [UIFont systemFontOfSize:14];
        txTitleLabel.textColor = [UIColor colorWithHexString:@"#1F1F1F"];
        txTitleLabel.textAlignment = NSTextAlignmentRight;
        [txDetailContainerSubView addSubview:txTitleLabel];
        [txTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(txDetailContainerSubView);
            make.width.mas_equalTo(100);
        }];
      
        
        UILabel *txContent = [[UILabel alloc] init];
        txContent.numberOfLines = 0;
        txContent.font = [UIFont systemFontOfSize:14];
        txContent.textColor = [UIColor colorWithHexString:@"#1F1F1F"];
        NSString *title = @"";
        switch (i) {
            case 0:{
                title = [LanguageService contentForKey:@"txid"];
                txContent.text = (self.txLog.tx_slate_id ? self.txLog.tx_slate_id :  [LanguageService contentForKey:@"unreachable"]);
            }
                break;
            case 1:{
                title = [LanguageService contentForKey:@"txAmount"];
                uint64_t amount = llabs((int64_t)self.txLog.amount_credited - (int64_t)self.txLog.amount_debited);
                NSString *amountStr = @([WalletWrapper nanoToVcash:amount]).p09fString;
                txContent.text = [NSString stringWithFormat:@"%@ VCash", amountStr];
            }
                break;
            case 2:{
                title = [LanguageService contentForKey:@"txfee"];
                txContent.text = [NSString stringWithFormat:@"%@ VCash", @([WalletWrapper nanoToVcash:self.txLog.fee]).p09fString];
            }
               
                break;
            case 3:
                 title = [LanguageService contentForKey:@"txtime"];
                 txContent.text =  self.txLog.create_time > 0 ? [[NSDate dateWithTimeIntervalSince1970:self.txLog.create_time] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"] : @"none";//[[NSDate date] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"]
                break;
            default:
                break;
        }
    
        txTitleLabel.text = title;
        [txDetailContainerSubView addSubview:txContent];
        [txContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(txTitleLabel);
            make.left.equalTo(txDetailContainerSubView).offset(114);
            make.right.equalTo(txDetailContainerSubView).offset(-15);
            make.bottom.equalTo(txDetailContainerSubView);
        }];
        priTxDetailSubview = txDetailContainerSubView;
    }
    
//    [priTxDetailSubview layoutIfNeeded];
//
//    [txDetailContainer mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.offset(28);
//        make.right.offset(-28);
//        make.top.equalTo(txDetailLabel.mas_bottom).offset(10);
//        make.height.mas_equalTo(priTxDetailSubview.origin.y + priTxDetailSubview.frame.size.height + 15);
//    }];
    
    _signTxFileContontTexView = [[UITextView alloc] init];
    _signTxFileContontTexView.font = [UIFont systemFontOfSize:14];
    _signTxFileContontTexView.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
    _signTxFileContontTexView.textColor = [UIColor colorWithHexString:@"#1F1F1F"];
    _signTxFileContontTexView.textContainerInset = UIEdgeInsetsMake(15, 0, 15, 15);
    _signTxFileContontTexView.text = self.txLog.signed_slate_msg;
    _signTxFileContontTexView.editable = NO;
    [signTxFileContentView addSubview:_signTxFileContontTexView];
    [_signTxFileContontTexView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(15);
        make.right.offset(0);
        make.top.bottom.offset(0);
    }];
    
}



- (void)copyFileContent{
    if (self.signTxFileContontTexView.text.length > 0) {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        [pasteBoard setString:self.signTxFileContontTexView.text];
        [self.view makeToast:[LanguageService contentForKey:@"copySuc"]];
    }
}

- (void)backBtnClicked{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.navigationController popViewControllerAnimated:YES];
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
