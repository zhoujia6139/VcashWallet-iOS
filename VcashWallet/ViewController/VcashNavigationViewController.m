//
//  VcashNavigationViewController.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/22.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "VcashNavigationViewController.h"

@interface VcashNavigationViewController ()<UIGestureRecognizerDelegate>

@end

@implementation VcashNavigationViewController

+ (void)initialize{
    UINavigationBar *naviBar = [UINavigationBar appearance];
    [naviBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [naviBar setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor darkTextColor], NSFontAttributeName : [UIFont systemFontOfSize:17]}];
//    [naviBar setShadowImage:[UIImage new]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.interactivePopGestureRecognizer.enabled = YES;
    self.interactivePopGestureRecognizer.delegate = self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return  [self.childViewControllers count] == 1 ? NO:YES;
}


- (UIViewController *)childViewControllerForStatusBarStyle{
    return self.topViewController;
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}


- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
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
