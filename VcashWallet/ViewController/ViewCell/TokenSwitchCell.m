//
//  TokenSwitchCell.m
//  VcashWallet
//
//  Created by jia zhou on 2020/1/14.
//  Copyright © 2020年 blockin. All rights reserved.
//

#import "TokenSwitchCell.h"

@interface TokenSwitchCell()
@property (weak, nonatomic) IBOutlet UIImageView *token_icon;

@property (weak, nonatomic) IBOutlet UILabel *token_name;

@property (weak, nonatomic) IBOutlet UILabel *token_full_name;

@property (weak, nonatomic) IBOutlet UISwitch *isAdd;

@end

@implementation TokenSwitchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setTokenType:(NSString*)tokenType {
    _tokenType = tokenType;
    VcashTokenInfo* info = [WalletWrapper getTokenInfo:tokenType];
    if (info) {
        NSString* iconUrl = [NSString stringWithFormat:@"%@%@", TokenIconUrlPrefix, info.IconName];
        [self.token_icon setImageWithURL:[NSURL URLWithString:iconUrl] placeholder:[UIImage imageNamed:@"default_token_icon.png"]];
        self.token_name.text = info.Name;
        self.token_full_name.text = info.FullName;
    } else {
        self.token_name.text = [tokenType substringToIndex:8];
        self.token_full_name.text = @"";
    }
    
    NSArray* addedToken = [WalletWrapper getAddedTokens];
    self.isAdd.on = [addedToken containsObject:tokenType];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)switchValueChanged:(id)sender {
    if (self.isAdd.on){
        [WalletWrapper addAddedToken:self.tokenType];
    } else {
        [WalletWrapper deleteAddedToken:self.tokenType];
    }
}

@end
