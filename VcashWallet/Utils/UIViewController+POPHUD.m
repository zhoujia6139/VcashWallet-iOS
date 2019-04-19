//
//  UIViewController+POPHUD.m
//  XMOrg
//
//  Created by chenwei on 2017/3/10.
//  Copyright © 2017年 jiejing. All rights reserved.
//

#import "UIViewController+POPHUD.h"

@implementation UIViewController (POPHUD)

@dynamic HUD;

- (MBProgressHUD *)HUD {
    return objc_getAssociatedObject(self, @"hud");
}

- (void)setHUD:(MBProgressHUD *)HUD {
    objc_setAssociatedObject(self, @"hud", HUD, OBJC_ASSOCIATION_RETAIN);
}

- (void)ex_showLoadingHUD {
    [self.HUD hideAnimated:NO];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.label.text = @"加载中...";
//    self.HUD.backgroundView.style = MBProgressHUDBackgroundStyleBlur;
//    self.HUD.backgroundView.color = CLineColor;
}

- (void)ex_showWiteLoadingHUD{
    [self.HUD hideAnimated:NO];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.label.text = @"加载中...";
    self.HUD.backgroundView.style = MBProgressHUDBackgroundStyleBlur;
}

- (void)ex_showLoadingHudForWindow{
    [self.HUD hideAnimated:NO];
    UIWindow *wd = [UIApplication sharedApplication].keyWindow;
    self.HUD = [MBProgressHUD showHUDAddedTo:wd animated:YES];
    self.HUD.label.text = @"";
}

- (void)ex_hideHUD {
    [self.HUD hideAnimated:YES afterDelay:0.25];
}

@end
