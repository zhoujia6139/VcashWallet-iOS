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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self animationAlert:self.viewContent];
    });
}

- (void)animationAlert:(UIView *)view{
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.0f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [view.layer addAnimation:popAnimation forKey:nil];
    
}

- (void)setProgress:(float)progress{
    self.progressBar.progress = progress;
    self.constraintLabelProgressLeading.constant = (ScreenWidth - 60 - 34) * progress;
    self.labelProgress.text = [NSString stringWithFormat:@"%.0f%%",progress * 100];
    if (progress == 1) {
        self.hidden = YES;
        [self removeFromSuperview];
        if (self.restoreSuccessCallBack) {
            self.restoreSuccessCallBack();
        }
    }
}

@end
