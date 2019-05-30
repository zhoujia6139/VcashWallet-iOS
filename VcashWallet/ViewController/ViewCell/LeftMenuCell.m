//
//  LeftMenuCell.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/23.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "LeftMenuCell.h"
#import "LeftMenuModel.h"

#define COrangeColor [UIColor colorWithHexString:@"#FF9502"]

@interface LeftMenuCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imagViewIcon;

@property (weak, nonatomic) IBOutlet UILabel *lableTitle;

@end

@implementation LeftMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(LeftMenuModel *)model{
    if(!model) return;
    NSString *imageName = model.selected ? model.imageHightName : model.imageName;
    self.lableTitle.textColor = model.selected ? COrangeColor : [UIColor darkTextColor];
    self.imageView.image = [UIImage imageNamed:imageName];
    self.lableTitle.text = model.title;
}


@end
