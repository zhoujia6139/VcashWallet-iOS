//
//  BaseViewController.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/22.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "BaseViewController.h"
#import "leftMenuView.h"

@interface BaseViewController ()

@property (nonatomic, strong) LeftMenuView *leftMenuView;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isShowLeftBack = YES;
}

- (void)setIsShowLeftBack:(BOOL)isShowLeftBack{
    NSInteger VCCount = self.navigationController.viewControllers.count;
    if (isShowLeftBack && ( VCCount > 1 || self.navigationController.presentingViewController != nil)) {
        [self addNavigationItemWithImageNames:@[@"back"] isLeft:YES target:self action:@selector(backBtnClicked) tags:nil];
        
    } else {
        self.navigationItem.hidesBackButton = YES;
        UIBarButtonItem * NULLBar=[[UIBarButtonItem alloc]initWithCustomView:[UIView new]];
        self.navigationItem.leftBarButtonItem = NULLBar;
    }
}

- (void)setIsShowLeftMeue:(BOOL)isShowLeftMeue{
    if (isShowLeftMeue) {
        [self.leftMenuView addInView];
        [self addNavigationItemWithImageNames:@[@"walletleftimage"] isLeft:YES target:self action:@selector(showLeftMenu:) tags:nil];
    }
}

- (void)showLeftMenu:(UIButton *)btn{
    btn.selected = !btn.selected;
    btn.selected ? [self.leftMenuView showAnimation] : [self.leftMenuView hiddenAnimation];
}
    

- (void)backBtnClicked{
    if (self.presentingViewController) {
        if (self.navigationController.childViewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (NSMutableArray <UIButton *> *)addNavigationItemWithImageNames:(NSArray *)imageNames isLeft:(BOOL)isLeft target:(id)target action:(SEL)action tags:(NSArray *)tags
{
    NSMutableArray * items = [[NSMutableArray alloc] init];
    NSMutableArray *arrBtn  = [NSMutableArray array];
    
    NSInteger i = 0;
    for (NSString * imageName in imageNames) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        btn.frame = CGRectMake(0, 0, 40, 40);
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        if (isLeft) {
            [btn setContentEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
        }else{
            [btn setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -20)];
        }
        
        btn.tag = [tags[i++] integerValue];
        UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:btn];
        [items addObject:item];
        [arrBtn addObject:btn];
    }
    if (isLeft) {
        self.navigationItem.leftBarButtonItems = items;
    } else {
        self.navigationItem.rightBarButtonItems = items;
    }
    return arrBtn;
}

#pragma mark - Lazy
- (LeftMenuView *)leftMenuView{
    if (!_leftMenuView) {
        _leftMenuView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LeftMenuView class]) owner:nil options:nil] firstObject];
        _leftMenuView.delegate = self;
    }
    return _leftMenuView;
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
