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

@interface MessageNotificationView ()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;


@end


@implementation MessageNotificationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (IBAction)clickedBtnSeeDetail:(id)sender {
    [self hiddenAnimation];
    [self pushTransactionDetailVc];
}

- (void)pushTransactionDetailVc{
    TransactionDetailViewController *transactionDetailVc = [[TransactionDetailViewController alloc] init];
    transactionDetailVc.serverTx = self.serverTx;
    [[[[AppHelper shareInstance] visibleViewController] navigationController] pushViewController:transactionDetailVc animated:YES];
}

- (IBAction)clickedBtnNoProcess:(id)sender {
    [self hiddenAnimation];
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
    CGFloat height = [self selfHeight];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wd.mas_top).offset(-height);
        make.left.right.equalTo(wd);
        make.height.mas_equalTo(height);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(wd);
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
            make.top.equalTo(wd.mas_top).offset(-[self selfHeight]);
        }];
        [wd layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}





@end
