//
//  AlertView.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/22.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "AlertView.h"

@interface AlertView ()

@property (weak, nonatomic) IBOutlet UIView *alphaView;


@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet VcashLabel *titleLabel;

@property (weak, nonatomic) IBOutlet VcashLabel *msgLabel;


@end

@implementation AlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib{
    [super awakeFromNib];
    ViewRadius(self.contentView, 8.0);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(remove)];
    [self.alphaView addGestureRecognizer:tap];
}


- (IBAction)clickedBtnDone:(id)sender {
    [self remove];
    if (self.doneCallBack) {
        self.doneCallBack();
    }
}

- (IBAction)clickedBtnCancel:(id)sender {
    [self remove];
}

- (void)show{
    UIWindow *wd = [UIApplication sharedApplication].keyWindow;
    [wd addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(wd);
    }];
}

- (void)remove{
    [self removeFromSuperview];
}

@end
