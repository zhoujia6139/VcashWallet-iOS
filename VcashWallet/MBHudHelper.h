//
//  MBHudHelper.h
//  PoolNativeApp
//
//  Created by jia zhou on 2018/3/15.
//  Copyright © 2018年 jia zhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBHudHelper : NSObject

+(void)showTextTips:(NSString*)tips onView:(UIView*)view withDuration:(NSTimeInterval)duration;

+(void)startWorkProcessWithTextTips:(NSString*)tips;

+(void)endWorkProcessWithSuc:(BOOL)isSuc andTextTips:(NSString*)tips;

@end
