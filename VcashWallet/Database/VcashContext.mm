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
#import <WCDB/WCDB.h>

@implementation VcashCommitId

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.keyPath forKey:@"keyPath"];
    [aCoder encodeObject:self.mmr_index forKey:@"mmr_index"];
    [aCoder encodeObject:@(self.value) forKey:@"value"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.keyPath = [aDecoder decodeObjectForKey:@"keyPath"];
        self.mmr_index = [aDecoder decodeObjectForKey:@"mmr_index"];
        NSNumber* value = (NSNumber*)[aDecoder decodeObjectForKey:@"value"];
        self.value = value.unsignedLongLongValue;
    }
    
    return self;
}

@end

@implementation VcashContext

-(id)init{
    self = [super init];
    if (self){
        _sec_nounce = [[VcashWallet shareInstance].mKeyChain.secp exportSecnonceSingle];;
    }
    _output_ids = [NSMutableArray new];
    _input_ids = [NSMutableArray new];
    _token_output_ids = [NSMutableArray new];
    _token_input_ids = [NSMutableArray new];
    return self;
}

WCDB_IMPLEMENTATION(VcashContext)
WCDB_SYNTHESIZE(VcashContext, sec_key)
WCDB_SYNTHESIZE(VcashContext, token_sec_key)
WCDB_SYNTHESIZE(VcashContext, sec_nounce)
WCDB_SYNTHESIZE(VcashContext, slate_id)

WCDB_SYNTHESIZE(VcashContext, amount)
WCDB_SYNTHESIZE(VcashContext, fee)
WCDB_SYNTHESIZE(VcashContext, output_ids)
WCDB_SYNTHESIZE(VcashContext, input_ids)
WCDB_SYNTHESIZE(VcashContext, token_output_ids)
WCDB_SYNTHESIZE(VcashContext, token_input_ids)

WCDB_PRIMARY(VcashContext, slate_id)

@end
