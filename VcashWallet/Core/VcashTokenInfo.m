//
//  VcashTokenInfo.m
//  VcashWallet
//
//  Created by jia zhou on 2020/1/13.
//  Copyright © 2020年 blockin. All rights reserved.
//

#import "VcashTokenInfo.h"

@implementation VcashTokenInfo

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.TokenId forKey:@"TokenId"];
    [aCoder encodeObject:self.Name forKey:@"Name"];
    [aCoder encodeObject:self.FullName forKey:@"FullName"];
    [aCoder encodeObject:self.BriefInfo forKey:@"BriefInfo"];
    [aCoder encodeObject:self.DetailInfoUrl forKey:@"DetailInfoUrl"];
    [aCoder encodeObject:self.IconName forKey:@"IconName"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.TokenId = [aDecoder decodeObjectForKey:@"TokenId"];
        self.Name = [aDecoder decodeObjectForKey:@"Name"];
        self.FullName = [aDecoder decodeObjectForKey:@"FullName"];
        self.BriefInfo = [aDecoder decodeObjectForKey:@"BriefInfo"];
        self.DetailInfoUrl = [aDecoder decodeObjectForKey:@"DetailInfoUrl"];
        self.IconName = [aDecoder decodeObjectForKey:@"IconName"];
    }
    
    return self;
}


@end
