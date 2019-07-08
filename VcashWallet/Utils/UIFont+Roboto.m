//
//  UIFont+Roboto.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/7/8.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "UIFont+Roboto.h"

@implementation UIFont (Roboto)

+ (UIFont *)robotoRegularWithSize:(CGFloat)fontSize{
    static NSString *name = @"Roboto-Regular";
    UIFont *font = [UIFont fontWithName:name size:fontSize];
    if (!font) {
        font = [UIFont systemFontOfSize:fontSize];
    }
    return font;
}

+ (UIFont *)robotoBoldWithSize:(CGFloat)fontSize{
    static NSString *name = @"Roboto-Bold";
    UIFont *font = [UIFont fontWithName:name size:fontSize];
    if (!font) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    }
    return font;
}

@end
