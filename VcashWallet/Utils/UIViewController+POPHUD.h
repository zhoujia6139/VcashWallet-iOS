//
//  UIViewController+POPHUD.h
//  XMOrg
//
//  Created by chenwei on 2017/3/10.
//  Copyright © 2017年 jiejing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface UIViewController (POPHUD) <MBProgressHUDDelegate>

@property (nonatomic, strong) MBProgressHUD *HUD;

- (void)ex_showLoadingHUD;

- (void)ex_showWiteLoadingHUD;

- (void)ex_showLoadingHudForWindow;

- (void)ex_hideHUD;

@end
