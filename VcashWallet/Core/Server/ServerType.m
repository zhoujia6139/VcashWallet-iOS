//
//  ServerType.m
//  VcashWallet
//
//  Created by jia zhou on 2019/5/6.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "ServerType.h"
#import "VcashSlate.h"
#import "WalletWrapper.h"

@implementation ServerTransaction

-(id)initWithSlate:(VcashSlate*)slate{
    self = [super init];
    if (self){
        _tx_id = slate.uuid;
        _slate = [WalletWrapper encryptSlateForParter:slate];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    return [self modelInitWithCoder:aDecoder];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    return [self modelEncodeWithCoder:aCoder];
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {

    self.sender_id = [WalletWrapper getProofAddressFromPublicKey:dic[@"sender_id"]];
    self.receiver_id = [WalletWrapper getProofAddressFromPublicKey:dic[@"receiver_id"]];
    
    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    dic[@"sender_id"] = [WalletWrapper getPubkeyFromProofAddress:self.sender_id];
    dic[@"receiver_id"] = [WalletWrapper getPubkeyFromProofAddress:self.receiver_id];
    
    return YES;
}

-(NSData*)msgToSign{
    NSString* textId = [self.tx_id stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSData* tx = BTCDataFromHex(textId);
    NSString* senderPubkey = [WalletWrapper getPubkeyFromProofAddress:self.sender_id];
    NSData* sender = BTCDataFromHex(senderPubkey);
    NSString* receiverPubkey = [WalletWrapper getPubkeyFromProofAddress:self.receiver_id];
    NSData* receiver = BTCDataFromHex(receiverPubkey);
    NSMutableData* data = [[NSMutableData alloc] initWithData:tx];
    [data appendData:sender];
    [data appendData:receiver];
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
