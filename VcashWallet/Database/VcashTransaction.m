//
//  VcashTransaction.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashTransaction.h"

@implementation Input

@end

@implementation Output

@end

@implementation TxKernel

@end

@implementation TransactionBody

-(id)init{
    self = [super init];
    if (self){
        _inputs = [NSMutableArray new];
        _outputs = [NSMutableArray new];
        _kernels = [NSMutableArray new];
    }
    return self;
}

@end

@implementation VcashTransaction

@end
