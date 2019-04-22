//
//  NodeApi.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/22.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NodeType.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^RequestCompleteBlock) (BOOL, _Nullable id);

@interface NodeApi : NSObject

+(void)getOutputsByPmmrIndex:(uint64_t)startheight retArr:(NSMutableArray*)retArr WithComplete:(RequestCompleteBlock)block;

@end

NS_ASSUME_NONNULL_END