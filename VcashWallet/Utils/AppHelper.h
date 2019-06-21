//
//  AppHelper.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/22.
//  Copyright © 2019 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define CLineColor [UIColor colorWithHexString:@"#dddddd"]

#define VLineWidth 1.0 / [UIScreen mainScreen].scale

@interface AppHelper : NSObject

+ (instancetype)shareInstance;

+ (UIView *)addLineTopWithParentView:(UIView *)iv;

+ (UIView *)addLineWithParentView:(UIView *)iv;

+ (UIView *)addLineWithParentViewLeftMargin15:(UIView *)iv;

+ (UIView *)addLineTopWithParentView:(UIView *)iv leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin lineHeight:(CGFloat)lineHeight;

+ (UIView *)addLineBottomWithParentView:(UIView *)iv leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin;

+ (UIView *)addLineBottomWithParentView:(UIView *)iv leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin lineHeight:(CGFloat)lineHeight;

+ (UIView *)addLineRightWithParentView:(UIView *)iv;

+ (UIView *)addLineLeftWithParentView:(UIView *)iv;

+ (UIView *)addLineVerRightWithParentView:(UIView *)iv top:(CGFloat)top bottom:(CGFloat)bottom lineWidth:(CGFloat)lineWidth linecolor:(UIColor *)linecolor;

- (UIViewController *)visibleViewController;

+ (BOOL)isPureInt:(NSString*)string;

@end

NS_ASSUME_NONNULL_END
