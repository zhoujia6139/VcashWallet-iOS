//
//  BaseTableViewCell.m
//  PoolinWallet
//
//  Created by 盛杰厚 on 2020/1/6.
//  Copyright © 2020 盛杰厚. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface BaseTableViewCell ()

@property (nonatomic, strong)   UIView *selectView;

@end

@implementation BaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _selectView = [UIView new];
       _selectView.backgroundColor = [UIColor colorWithRed:209 / 255.0 green:209 / 255.0 blue:213 / 255.0 alpha:1.0];
       self.selectedBackgroundView = _selectView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _selectView.frame = CGRectMake(0, 0, ScreenWidth, self.bounds.size.height);
}

@end
