//
//  JsonRpc.h
//  VcashWallet
//
//  Created by jia zhou on 2019/12/9.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JsonRpc : NSObject

@property(strong, nonatomic)NSString* jsonrpc;

@property(strong, nonatomic)NSString* method;

@property(assign, nonatomic)int num_id;

@property(strong, nonatomic)NSArray* params;

- (id) initWithParam:(NSString*)param;

@end

@interface JsonRpcRes : NSObject

@property(strong, nonatomic)NSString* jsonrpc;

@property(strong, nonatomic)NSDictionary* result;

@property(assign, nonatomic)int num_id;

@property(strong, nonatomic)NSDictionary* error;

- (id) initWithParam:(NSString*)param;

@end

NS_ASSUME_NONNULL_END
