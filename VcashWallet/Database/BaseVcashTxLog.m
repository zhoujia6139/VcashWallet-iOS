//
//  BaseVcashTxLog.m
//  VcashWallet
//
//  Created by jia zhou on 2019/12/25.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "BaseVcashTxLog.h"

@implementation BaseVcashTxLog

-(BOOL)isCanBeCanneled{
    if (self.tx_type == TxSent && self.confirm_state == DefaultState){
        return YES;
    }else if (self.tx_type == TxReceived && !self.parter_id && self.signed_slate_msg && self.confirm_state != NetConfirmed){
        return YES;
    }
    
    return NO;
}

-(BOOL)isCanBeAutoCanneled{
    if ((self.tx_type == TxSent || self.tx_type == TxReceived) &&
        self.confirm_state == DefaultState) {
        return YES;
    }
    
    return NO;
}

-(void)cancelTxlog{
    
}

@end
