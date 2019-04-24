//
//  PublicTool.h
//  VcashWallet
//
//  Created by jia zhou on 2019/4/24.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PublicTool : NSObject

+(NSData*)getDataFromArray:(NSArray*)array;

+(NSArray*)getArrFromData:(NSData*)data;

@end

NS_ASSUME_NONNULL_END
