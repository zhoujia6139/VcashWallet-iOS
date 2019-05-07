//
//  ServerApi.h
//  VcashWallet
//
//  Created by jia zhou on 2019/5/6.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerType.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^RequestCompleteBlock) (BOOL, _Nullable id);

@interface ServerApi : NSObject

+ (instancetype)shareInstance;

-(void)checkStatusForUser:(NSString*)userId WithComplete:(RequestCompleteBlock)block;

-(void)sendTransaction:(ServerTransaction*)tx WithComplete:(RequestCompleteBlock)block;

-(void)receiveTransaction:(ServerTransaction*)tx WithComplete:(RequestCompleteBlock)block;

-(void)filanizeTransaction:(ServerTransaction*)tx;

@end

NS_ASSUME_NONNULL_END
