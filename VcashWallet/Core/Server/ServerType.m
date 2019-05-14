//
//  ServerType.m
//  VcashWallet
//
//  Created by jia zhou on 2019/5/6.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "ServerType.h"
#import "VcashSlate.h"

@implementation ServerTransaction

-(id)initWithSlate:(VcashSlate*)slate{
    self = [super init];
    if (self){
        _tx_id = slate.uuid;
        _slate = [slate modelToJSONString];
    }
    return self;
}

+ (NSArray *)modelPropertyBlacklist {
    return @[@"slateObj", @"isSend"];
}

@end
