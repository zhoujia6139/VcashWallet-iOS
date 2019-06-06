//
//  VcashButton.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/22.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "VcashButton.h"

@implementation VcashButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setLocalTitle:(NSString *)localTitle{
    if (!localTitle) {
        return;
    }
    [self setTitle:[LanguageService contentForKey:localTitle] forState:UIControlStateNormal];
}


@end