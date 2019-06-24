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

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    return [self modelInitWithCoder:aDecoder];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    return [self modelEncodeWithCoder:aCoder];
}

-(Boolean)isValidTxSignature{
    if (self.status == TxDefaultStatus){
        return YES;
    }
    else if (self.status == TxReceiverd){
        VcashSecp256k1* secp = [VcashWallet shareInstance].mKeyChain.secp;
        NSData* pubkeyData = BTCDataFromHex(self.receiver_id);
        return [secp ecdsaVerify:[self txDataToSign] sigData:BTCDataFromHex(self.tx_sig) pubkey:pubkeyData];
    }
    
    return NO;
}

-(NSData*)msgToSign{
    NSString* textId = [self.tx_id stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSData* tx = BTCDataFromHex(textId);
    NSData* sender = BTCDataFromHex(self.sender_id);
    NSData* receiver = BTCDataFromHex(self.receiver_id);
    NSMutableData* data = [[NSMutableData alloc] initWithData:tx];
    [data appendData:sender];
    [data appendData:receiver];
    return data;
}

-(NSData*)txDataToSign{
    NSString* textId = [self.tx_id stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSData* tx = BTCDataFromHex(textId);
    NSData* sender = BTCDataFromHex(self.sender_id);
    NSData* receiver = BTCDataFromHex(self.receiver_id);
    NSData* txData = [self.slateObj.tx computePayloadForHash:YES];
    NSMutableData* data = [[NSMutableData alloc] initWithData:tx];
    [data appendData:sender];
    [data appendData:receiver];
    [data appendData:txData];
    return data;
}

@end

@implementation FinalizeTxInfo

-(NSData*)msgToSign{
    NSString* textId = [self.tx_id stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSData* tx = BTCDataFromHex(textId);
    NSMutableData* data = [[NSMutableData alloc] initWithData:tx];
    uint8_t byte = self.code;
    [data appendBytes:&byte length:1];
    return data;
}

@end
