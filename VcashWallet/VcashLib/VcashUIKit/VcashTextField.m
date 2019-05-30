//
//  VcashTextField.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/22.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "VcashTextField.h"

@implementation VcashTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setLocalText:(NSString *)localText{
    if (!localText) {
        return;
    }
    self.text = [LanguageService contentForKey:localText];
}

- (void)setLocalPlaceholder:(NSString *)localPlaceholder{
    if (!localPlaceholder) {
        return;
    }
    self.placeholder = [LanguageService contentForKey:localPlaceholder];
}
@end
