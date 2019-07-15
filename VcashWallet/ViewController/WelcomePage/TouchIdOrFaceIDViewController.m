//
//  TouchIdOrFaceIDViewController.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/7/15.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "TouchIdOrFaceIDViewController.h"
#import "LocalAuthenticationManager.h"

@interface TouchIdOrFaceIDViewController ()

@end

@implementation TouchIdOrFaceIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self verifyIdentifier];
}

- (void)verifyIdentifier{
    __weak typeof(self) weakSelf = self;
    [[LocalAuthenticationManager shareInstance] verifyIdentidyWithComplete:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (IBAction)clickedBtnScan:(id)sender {
    [self verifyIdentifier];
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
