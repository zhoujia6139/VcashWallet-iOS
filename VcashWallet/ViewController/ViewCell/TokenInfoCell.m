//
//  TokenInfoCell.m
//  VcashWallet
//
//  Created by jia zhou on 2020/1/13.
//  Copyright © 2020年 blockin. All rights reserved.
//

#import "TokenInfoCell.h"
#import "WalletWrapper.h"
#import "VcashTokenInfo.h"

@interface TokenInfoCell()
@property (weak, nonatomic) IBOutlet UIImageView *token_icon;

@property (weak, nonatomic) IBOutlet UILabel *token_name;

@property (weak, nonatomic) IBOutlet UILabel *token_full_name;

@property (weak, nonatomic) IBOutlet UILabel *amount;

@end

@implementation TokenInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setTokenType:(NSString*)tokenType {
    _tokenType = tokenType;
    WalletBalanceInfo* balance;
    if ([tokenType isEqualToString:@"VCash"]) {
        self.token_icon.image = [UIImage imageNamed:@"vc_icon.png"];
        self.token_name.text = @"VCash";
        self.token_full_name.text = @"";
        balance = [WalletWrapper getWalletBalanceInfo];
    } else {
        VcashTokenInfo* info = [WalletWrapper getTokenInfo:tokenType];
        NSString* iconUrl = [NSString stringWithFormat:@"%@%@", TokenIconUrlPrefix, info.IconName];
        [self.token_icon setImageWithURL:[NSURL URLWithString:iconUrl] placeholder:[UIImage imageNamed:@"default_token_icon.png"]];
        self.token_name.text = info.Name;
        self.token_full_name.text = info.FullName;
        
        balance = [WalletWrapper getWalletTokenBalanceInfo:tokenType];
    }
    
    if (balance) {
        self.amount.text = [NSString stringWithFormat:@"%@", @([WalletWrapper nanoToVcash:balance.total])];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
