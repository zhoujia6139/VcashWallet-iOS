//
//  MBHudHelper.m
//  PoolNativeApp
//
//  Created by jia zhou on 2018/3/15.
//  Copyright © 2018年 jia zhou. All rights reserved.
//

#import "MBHudHelper.h"
#import "MBProgressHUD.h"
//#import "HudLabel.h"

@implementation MBHudHelper

+(void)showTextTips:(NSString*)tips onView:(UIView*)view withDuration:(NSTimeInterval)duration
{
    if (!view)
    {
        view = [UIApplication sharedApplication].keyWindow;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    // Set the text mode to show only text.
    hud.mode = MBProgressHUDModeText;
    hud.label.text = tips;
    hud.label.numberOfLines = 0;
    // Move to bottm center.
    hud.offset = CGPointMake(0.f, -20.f);
    
    [hud hideAnimated:YES afterDelay:duration];
}

+(void)startWorkProcessWithTextTips:(NSString*)tips
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    // Set the text mode to show only text.
    //hud.mode = MBProgressHUDModeText;
    if (tips)
    {
        hud.label.text = tips;
        hud.label.numberOfLines = 0;
    }
    
    // Move to bottm center.
    hud.offset = CGPointMake(0.f, -20.f);
    
    //[hud hideAnimated:YES afterDelay:duration];
}

+(void)endWorkProcessWithSuc:(BOOL)isSuc andTextTips:(NSString*)tips
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:[UIApplication sharedApplication].keyWindow];
    NSString* imageName = isSuc?@"process_suc_icon.png":@"process_fail_icon.png";
    UIView *iv = [[UIView alloc] init];
    UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = image;
    [iv addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iv);
        make.centerX.equalTo(iv);
        make.width.height.mas_equalTo(40);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.font = [UIFont boldSystemFontOfSize:16.0f];
    label.textColor = [UIColor colorWithWhite:0.f alpha:0.7f];
    label.text = tips;
    [iv addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom);
        make.left.right.bottom.equalTo(iv);
    }];
    
    hud.mode = MBProgressHUDModeCustomView;
    if (tips)
    {
        hud.customView = iv;
    }
//    hud.label.text = tips;
//    hud.label.numberOfLines = 0;
    NSTimeInterval interval = 1.5f;
    if (isSuc && !tips)
    {
        interval = 0.1f;
    }
    [hud hideAnimated:YES afterDelay:interval];
}

@end
