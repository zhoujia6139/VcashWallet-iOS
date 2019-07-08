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

@property (weak, nonatomic) IBOutlet UILabel *lablelTxID;

@property (weak, nonatomic) IBOutlet UILabel *labelAmount;

@property (weak, nonatomic) IBOutlet UILabel *labelFee;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewClose;

@property (weak, nonatomic) IBOutlet UIView *viewSendTo;

@property (weak, nonatomic) IBOutlet UILabel *labelSendTo;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTxAmountTopWithLabelSendto;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintViewSendToHeight;


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
    self.imageViewClose.userInteractionEnabled = YES;
    self.viewSendTo.hidden = YES;
    self.labelSendTo.preferredMaxLayoutWidth = ScreenWidth - 142;
    self.constraintViewSendToHeight.constant = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenAnimation)];
    [self.imageViewClose addGestureRecognizer:tap];
}

- (void)setSlate:(VcashSlate *)slate{
    _slate = slate;
    NSString *amountStr = @([WalletWrapper nanoToVcash:slate.amount]).p09fString;
    self.lablelTxID.lineBreakMode = NSLineBreakByCharWrapping;
    self.lablelTxID.text = slate.uuid;
    NSMutableAttributedString *amountAttributeStr = [[NSMutableAttributedString alloc] initWithString:amountStr attributes:@{NSFontAttributeName:[UIFont robotoBoldWithSize:14]}];
    NSAttributedString *unitAttributeStr = [[NSAttributedString alloc] initWithString:@" VCash" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    [amountAttributeStr appendAttributedString:unitAttributeStr];
    self.labelAmount.attributedText = amountAttributeStr;
    
    NSMutableAttributedString *feeAttributeStr = [[NSMutableAttributedString alloc] initWithString:@([WalletWrapper nanoToVcash:slate.fee]).p09fString attributes:@{NSFontAttributeName:[UIFont robotoBoldWithSize:14]}];
    [feeAttributeStr appendAttributedString:unitAttributeStr];
    self.labelFee.attributedText = feeAttributeStr;
}

- (void)setSenderAddress:(NSString *)senderAddress{
    _senderAddress = senderAddress;
    if (!senderAddress) {
        return;
    }
    self.labelSendTo.text = senderAddress;
    self.viewSendTo.hidden = NO;
    CGFloat viewSendHeight = [self.labelSendTo sizeThatFits:CGSizeMake(ScreenWidth - 142, 1000)].height + 20;
    self.constraintViewSendToHeight.constant = viewSendHeight;
}

- (void)setBtnTitle:(NSString *)btnTitle{
    _btnTitle = btnTitle;
    [self.signTxBtn setTitle:btnTitle forState:UIControlStateNormal];
}


- (IBAction)clickedBtnSignTx:(id)sender {
    //sign tx callBack
    if (self.signCallBack) {
        self.signCallBack(self.slate);
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
