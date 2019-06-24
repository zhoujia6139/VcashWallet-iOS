//
//  TransactionDetailView.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/6/21.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "TransactionDetailView.h"

@interface TransactionDetailView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *signTxBtn;


@end

@implementation TransactionDetailView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
 
*/

- (void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    ViewRadius(self.contentView, 4.0);
    ViewRadius(self.signTxBtn, 4.0);
}


- (IBAction)clickedBtnSignTx:(id)sender {
    //sign tx callBack
    if (self.signCallBack) {
        self.signCallBack();
    }
    [self hiddenAnimation];
}

- (void)show{
    if (!self.superview) {
        UIWindow *wd = [UIApplication sharedApplication].keyWindow;
        [wd addSubview:self];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(wd);
        }];
    }
}

- (void)hiddenAnimation{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


@end
