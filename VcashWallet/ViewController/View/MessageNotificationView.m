//
//  MessageNotificationView.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/27.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "MessageNotificationView.h"
#import "ServerType.h"
#import "TransactionDetailViewController.h"
#import "ServerTransactionBlackManager.h"
#import "ServerTxManager.h"

@interface MessageNotificationView ()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet UIButton *seeDetailBtn;


@end


@implementation MessageNotificationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib{
   [super awakeFromNib];
    self.messageLabel.preferredMaxLayoutWidth = ScreenWidth - 46 - 24;
}

- (void)setServerTx:(ServerTransaction *)serverTx{
    _serverTx = serverTx;
    if (_serverTx.isSend) {
        self.messageLabel.text = [LanguageService contentForKey:@"senderMsgNoti"];
    }else{
        self.messageLabel.text = [LanguageService contentForKey:@"receiverMsgNoti"];
    }
}


- (IBAction)clickedBtnSeeDetail:(id)sender {
    [self hiddenAnimation];
    [self pushTransactionDetailVc];
}

- (void)pushTransactionDetailVc{
    [[ServerTransactionBlackManager shareInstance] writeBlackServerTransaction:self.serverTx];
    TransactionDetailViewController *transactionDetailVc = [[TransactionDetailViewController alloc] init];
    transactionDetailVc.serverTx = self.serverTx;
    [[[[AppHelper shareInstance] visibleViewController] navigationController] pushViewController:transactionDetailVc animated:YES];
}

- (IBAction)clickedBtnNoProcess:(id)sender {
    [self hiddenAnimation];
    [[ServerTransactionBlackManager shareInstance] writeBlackServerTransaction:self.serverTx];
}

- (void)setMessage:(NSString *)message{
    if (!message) {
        return;
    }
    self.messageLabel.text = message;
}

- (void)show{
    UIWindow *wd = [UIApplication sharedApplication].keyWindow;
    [wd addSubview:self];
    [self layoutIfNeeded];
    ViewRadius(self, 4.0);
    ViewRadius(self.seeDetailBtn, 4.0);
    CGFloat height = [self selfHeight];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wd.mas_top).offset(-height - kStatusBarHeight);
        make.left.equalTo(wd).offset(12);
        make.right.equalTo(wd).offset(-12);
        make.height.mas_equalTo(height);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(wd).offset(kStatusBarHeight);
            }];
            [wd layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    });
}

- (CGFloat)selfHeight{
    return [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
}

- (void)hiddenAnimation{
    UIWindow *wd = [UIApplication sharedApplication].keyWindow;
    [UIView animateWithDuration:0.25 animations:^{
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(wd.mas_top).offset(-[self selfHeight] -kStatusBarHeight);
        }];
        [wd layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}





@end
