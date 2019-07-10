//
//  LeftMenuManager.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/6/10.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "LeftMenuManager.h"


@interface LeftMenuManager ()<UIGestureRecognizerDelegate>

@end

@implementation LeftMenuManager

+ (id)shareInstance{
    static LeftMenuManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LeftMenuManager alloc] init];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.leftMenuView = [[LeftMenuView alloc] initWithFrame:CGRectMake(-ScreenWidth * 3 / 4, 0, ScreenWidth * 3 / 4, ScreenHeight)];
    }
    return self;
}

- (void)addInView{
    if (!self.leftMenuView.superview) {
        [self.leftMenuView addInView];
    }
}

- (void)removeGestures{
    UIWindow *wd = [UIApplication sharedApplication].keyWindow;
    [wd removeGestureRecognizer:self.panGesture];
}

- (void)addGestures{
    [self removeGestures];
    UIWindow *wd = [UIApplication sharedApplication].keyWindow;
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panLeftMenu:)];
    self.panGesture.delegate = self;
    [wd addGestureRecognizer:self.panGesture];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UIPanGestureRecognizer")]) {
        CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:gestureRecognizer.view];
        if (velocity.x < 0) {
            return NO;
        }
    }
    return YES;
}

- (void)panLeftMenu:(UIPanGestureRecognizer *)pan{
    CGPoint offSet = [pan translationInView:pan.view];
    CGPoint center = self.leftMenuView.center;
    if (self.leftMenuView.origin.x >= 0 && offSet.x > 0) {
        CGRect fra = self.leftMenuView.frame;
        fra.origin.x = 0;
        self.leftMenuView.frame = fra;
    }else{
        center.x = center.x + offSet.x;
        self.leftMenuView.center = center;
    }
    BOOL isLeft = NO;
    CGPoint velocity = [pan velocityInView:pan.view];
    if (velocity.x < 0) {
        isLeft = YES;
    }
    
    [pan setTranslation:CGPointZero inView:pan.view];
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (!isLeft) {
            if (self.leftMenuView.frame.origin.x >= (- ScreenWidth * 3 /4 + 80)) {
                [self.leftMenuView showAnimation];
            }else{
                [self.leftMenuView hiddenAnimation];
            }
        }else{
            [self.leftMenuView hiddenAnimation];
        }
        
    }
}


@end
