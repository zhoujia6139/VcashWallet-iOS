//
//  WalletPageSectionView.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/7/5.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "WalletPageSectionView.h"

@interface WalletPageSectionView ()

@property (nonatomic, strong) UILabel *labelTitle;

@end

@implementation WalletPageSectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor  = [UIColor colorWithHexString:@"#F8F8F8"];
        self.labelTitle = [[UILabel alloc] init];
        self.labelTitle.font = [UIFont systemFontOfSize:12];
        self.labelTitle.textColor = [UIColor colorWithHexString:@"#AEAEAE"];
        [self addSubview:self.labelTitle];
        [self.labelTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(15);
            make.centerY.equalTo(self);
        }];
    }
    return self;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    if (!title) {
        return;
    }
    self.labelTitle.text = title;
}

@end
