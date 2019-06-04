//
//  AppHelper.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/22.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "AppHelper.h"

@implementation AppHelper

+ (instancetype)shareInstance{
    static AppHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[AppHelper alloc] init];
    });
    return helper;
}

+ (UIView *)addLineTopWithParentView:(UIView *)iv{
    if (iv) {
        UIView *ivLine = [UIView new];
        ivLine.backgroundColor = CLineColor;
        [iv addSubview:ivLine];
        [ivLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(iv);
            make.height.mas_equalTo(VLineWidth);
        }];
        return ivLine;
    }
    return nil;
}

+ (UIView *)addLineWithParentView:(UIView *)iv{
    if (iv) {
        UIView *ivLine = [UIView new];
        ivLine.backgroundColor = CLineColor;
        ivLine.tag = 369;
        [iv addSubview:ivLine];
        [ivLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(iv);
            make.height.mas_equalTo(VLineWidth);
        }];
        return ivLine;
    }
    return nil;
}
+ (UIView *)addLineWithParentViewLeftMargin15:(UIView *)iv{
    if (iv) {
        UIView *ivLine = [UIView new];
        ivLine.backgroundColor = CLineColor;
        ivLine.tag = 398;
        [iv addSubview:ivLine];
        [ivLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iv).offset(15);
            make.right.bottom.equalTo(iv);
            make.height.mas_equalTo(VLineWidth);
        }];
        ivLine.userInteractionEnabled = NO;
        return ivLine;
    }
    return nil;
}

+ (UIView *)addLineWithParentView:(UIView *)iv leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin{
    if (iv) {
        UIView *ivLine = [UIView new];
        ivLine.backgroundColor = CLineColor;
        ivLine.tag = 369;
        [iv addSubview:ivLine];
        [ivLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(iv);
            make.left.equalTo(iv).offset(leftMargin);
            make.right.equalTo(iv).offset(-rightMargin);
            make.height.mas_equalTo(VLineWidth);
        }];
        return ivLine;
    }
    return nil;
}


+ (UIView *)addLineWithParentView:(UIView *)iv leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin lineHeight:(CGFloat)lineHeight{
    if (iv) {
        UIView *ivLine = [UIView new];
        ivLine.backgroundColor = CLineColor;
        ivLine.tag = 369;
        [iv addSubview:ivLine];
        [ivLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(iv);
            make.left.equalTo(iv).offset(leftMargin);
            make.right.equalTo(iv).offset(-rightMargin);
            make.height.mas_equalTo(lineHeight);
        }];
        return ivLine;
    }
    return nil;
}

+ (UIView *)addLineRightWithParentView:(UIView *)iv{
    if (iv) {
        UIView *ivLine = [UIView new];
        ivLine.backgroundColor = CLineColor;
        [iv addSubview:ivLine];
        [ivLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(iv);
            make.width.mas_equalTo(VLineWidth);
        }];
        return ivLine;
    }
    return nil;
}

+ (UIView *)addLineLeftWithParentView:(UIView *)iv{
    if (iv) {
        UIView *ivLine = [UIView new];
        ivLine.backgroundColor = CLineColor;
        [iv addSubview:ivLine];
        [ivLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.equalTo(iv);
            make.width.mas_equalTo(VLineWidth);
        }];
        return ivLine;
    }
    return nil;
}



+(UIView *)addLineVerRightWithParentView:(UIView *)iv top:(CGFloat)top bottom:(CGFloat)bottom lineWidth:(CGFloat)lineWidth linecolor:(UIColor *)linecolor{
    if (iv) {
        UIView *ivLine = [UIView new];
        if (!linecolor) {
            ivLine.backgroundColor = CLineColor;
        }else{
            ivLine.backgroundColor = linecolor;
        }
        [iv addSubview:ivLine];
        [ivLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(iv).offset(top);
            make.right.equalTo(iv);
            make.bottom.equalTo(iv).offset(-bottom);
            make.width.mas_equalTo(lineWidth);
        }];
        return ivLine;
    }
    return nil;
    
}


- (UIViewController *)visibleViewController{
    UIViewController *rootViewController =[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    return [self getVisibleViewControllerFrom:rootViewController];
}

- (UIViewController *) getVisibleViewControllerFrom:(UIViewController *) vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        
        return [self getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            
            return [self getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            
            return vc;
        }
    }
}

+ (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}
@end
