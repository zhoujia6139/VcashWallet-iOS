//
//  NodeType.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/22.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "NodeType.h"
#import "VcashTypes.h"

@implementation NodeOutput

@end

@implementation NodeOutputs

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return@{@"outputs" : [NodeOutput class]};
}

@end

@implementation NodeChainInfo

@end

@implementation NodeRefreshOutput

@end

@implementation NodeRefreshTokenOutput

@end

@implementation LocatedTxKernel

@end

@implementation LocatedTokenTxKernel

@end
