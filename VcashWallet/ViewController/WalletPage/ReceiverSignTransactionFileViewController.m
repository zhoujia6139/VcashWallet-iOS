//
//  ReceiverSignTransactionFileViewController.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/6/21.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "ReceiverSignTransactionFileViewController.h"

@interface ReceiverSignTransactionFileViewController ()

@property (nonatomic, strong) UITextView *signTxFileContontTexView;

@end

@implementation ReceiverSignTransactionFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    [self getSignTxFileContent];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled  = YES;
}

- (void)initView{
    self.title = [LanguageService contentForKey:@"receiveTransactionFile"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitleColor:[UIColor colorWithHexString:@"#FF9502"] forState:UIControlStateNormal];
    [rightBtn setTitle:[LanguageService contentForKey:@"done"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
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
    }];
    
    _signTxFileContontTexView = [[UITextView alloc] init];
    _signTxFileContontTexView.font = [UIFont systemFontOfSize:14];
    _signTxFileContontTexView.textColor = [UIColor colorWithHexString:@"#1F1F1F"];
//    _signTxFileContontLabel = @"某些研究需要敏感的数据集，比如学校营养午餐与学生健康之间的关系、企业薪资股权激励的有效性等，这些有价值的数据通常会涉及隐私信息。在经过多年努力之后，谷歌密码学家和数据科学家提出了一种全新的技术来实现这种“多方计算”（multiparty computation），而不会向任何无关的人公开信息 某些研究需要敏感的数据集，比如学校营养午餐与学生健康之间的关系、企业薪资股权激励的有效性等，这些有价值的数据通常会涉及隐私信息。在经过多年努力之后，谷歌密码学家和数据科学家提出了一种全新的技术来实现这种“多方计算”（multiparty computation），而不会向任何无关的人公开信息";
    [signTxFileContentView addSubview:_signTxFileContontTexView];
    [_signTxFileContontTexView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.offset(16);
        make.height.mas_equalTo(200);
        make.right.bottom.offset(-16);
    }];
    
}

- (void)getSignTxFileContent{
    if (!self.slate) {
        return;
    }
    [WalletWrapper receiveTransactionBySlate:self.slate withComplete:^(BOOL yesOrNo, id _Nullable data) {
        if (yesOrNo) {
            self.signTxFileContontTexView.text = data;
        }else{
            [self.view makeToast:data];
        }
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
    [self.navigationController popToRootViewControllerAnimated:YES];
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
