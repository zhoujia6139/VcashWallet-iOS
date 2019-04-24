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

-(void)setLock_height:(uint64_t)lock_height{
    _lock_height = lock_height;
    _features = lock_height>0?KernelFeatureHeightLocked:KernelFeaturePlain;
}

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
