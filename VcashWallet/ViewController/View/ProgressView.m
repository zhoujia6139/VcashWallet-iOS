//
//  ProgressView.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/6/14.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "ProgressView.h"

@interface ProgressView ()

@property (weak, nonatomic) IBOutlet UIView *viewContent;

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

@property (weak, nonatomic) IBOutlet UILabel *labelProgress;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLabelProgressLeading;
@end

@implementation ProgressView

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
    ViewRadius(self.viewContent, 6.0);
    ViewRadius(self.progressBar, 4.0);
}


- (void)show{
    UIWindow *wd = [UIApplication sharedApplication].keyWindow;
    [wd addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(wd);
    }];
}

- (void)setProgress:(float)progress{
    self.progressBar.progress = progress;
    self.constraintLabelProgressLeading.constant = (ScreenWidth - 60 - 34) * progress;
    self.labelProgress.text = [NSString stringWithFormat:@"%.0f%%",progress * 100];
    if (progress == 1) {
        self.hidden = YES;
        if (self.restoreSuccessCallBack) {
            self.restoreSuccessCallBack();
        }
    }
}

@end
