//
//  ServerType.m
//  VcashWallet
//
//  Created by jia zhou on 2019/5/6.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "ServerType.h"

@implementation ServerTransaction

-(id)init{
    self = [super init];
    if (self){
        _tx_id = BTCHexFromData(BTCRandomDataWithLength(16));
    }
    return self;
}

+ (NSArray *)modelPropertyBlacklist {
    return @[@"slateObj", @"isSend"];
}

@end
