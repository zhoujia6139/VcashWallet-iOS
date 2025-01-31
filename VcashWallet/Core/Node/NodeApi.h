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

+ (instancetype)shareInstance;

-(void)getOutputsByPmmrIndex:(uint64_t)startIndex WithComplete:(RequestCompleteBlock)completeblock;

-(void)getTokenOutputsByPmmrIndex:(uint64_t)startIndex WithComplete:(RequestCompleteBlock)completeblock;

-(void)getOutputsByCommitArr:(NSArray<NSString*>*)commitArr WithComplete:(RequestCompleteBlock)completeblock;

-(void)getTokenOutputsForToken:(NSString*)token_type WithCommitArr:(NSArray<NSString*>*)commitArr WithComplete:(RequestCompleteBlock)completeblock;

-(void)getKernel:(NSString*)excess WithComplete:(RequestCompleteBlock)completeblock;

-(void)getTokenKernel:(NSString*)tokenExcess WithComplete:(RequestCompleteBlock)completeblock;

-(uint64_t)getChainHeightWithComplete:(RequestCompleteBlock _Nullable)completeblock;

-(void)postTx:(NSString*)txHex WithComplete:(RequestCompleteBlock)completeblock;

@end

NS_ASSUME_NONNULL_END
