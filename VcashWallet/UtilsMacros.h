//
//  UtilsMacros.h
//  PoolNativeApp
//
//  Created by 盛杰厚 on 2018/3/19.
//  Copyright © 2018年 jia zhou. All rights reserved.
//

#ifndef UtilsMacros_h
#define UtilsMacros_h

#define kNetworkNotReachability ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus <= 0)

//获取系统对象
#define kApplication        [UIApplication sharedApplication]
#define kAppWindow          [UIApplication sharedApplication].delegate.window
#define kAppDelegate        [AppDelegate shareAppDelegate]
#define kRootViewController [UIApplication sharedApplication].delegate.window.rootViewController
#define kUserDefaults       [NSUserDefaults standardUserDefaults]
#define kNotificationCenter [NSNotificationCenter defaultCenter]

#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBarHeight 44.0
#define kTabBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?83:49)
#define kTopHeight (kStatusBarHeight + kNavBarHeight)

//物理屏
#define ScreenBounds [UIScreen mainScreen].bounds
//物理屏宽
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
//物理屏高
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
//判断机型
#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

//#define iPhoneX (@available(iOS 11.0, *) ？ [[[UIApplication sharedApplication] delegate] window].safeAreaInsets.bottom > 0.0 : NO )

#define iPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

#define Portrait_Bottom_SafeArea_Height (iPhoneX ? 34 : 0)

//强弱引用
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;


//View 圆角和加边框
#define ViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

// View 圆角
#define ViewRadius(View, Radius)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES]

//当前版本号
#define AppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

//拼接字符串
#define NSStringFormat(format,...) [NSString stringWithFormat:format,##__VA_ARGS__]

//颜色
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define COrangeColor  [UIColor colorWithHexString:@"#FF9502"]
#define COrangeHighlightedColor  [UIColor colorWithHexString:@"#D28924"]

#define COrangeEnableColor [UIColor colorWithHexString:@"#FFD8A0"]

#define CGrayColor [UIColor colorWithHexString:@"#EEEEEE"]
#define CGrayHighlightedColor    [UIColor colorWithHexString:@"#999999"]

#define CGreenColor  [UIColor colorWithHexString:@"#66CC33"]
#define CGreenHighlightedColor  [UIColor colorWithHexString:@"#6BA34F"]


#endif /* UtilsMacros_h */
