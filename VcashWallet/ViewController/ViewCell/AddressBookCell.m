//
//  AddressBookCell.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/7/12.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "AddressBookCell.h"

@interface AddressBookCell ()

@property (weak, nonatomic) IBOutlet UILabel *labelRemark;

@property (weak, nonatomic) IBOutlet UILabel *labelAddress;


@end

@implementation AddressBookCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [AppHelper addLineWithParentView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(AddressBookModel *)model{
    _model = model;
    self.labelRemark.text = model.remarkName;
    self.labelAddress.text = model.address;
}

@end
