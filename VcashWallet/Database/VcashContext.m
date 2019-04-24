//
//  VcashContext.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashContext.h"
#import "VcashWallet.h"
#import "VcashSecp256k1.h"

@implementation VcashContext

-(id)init{
    self = [super init];
    if (self){
        _sec_nounce = [[VcashWallet shareInstance].mKeyChain.secp exportSecnonceSingle];;
    }
    return self;
}

@end
