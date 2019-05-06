//
//  ServerType.h
//  VcashWallet
//
//  Created by jia zhou on 2019/5/6.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServerTransaction : NSObject

@property(strong, nonatomic) NSString* sender_id;

@property(strong, nonatomic) NSString* receiver_id;

@property(strong, nonatomic) NSString* slate;

@property(assign, nonatomic) uint8_t send_type;


@end

NS_ASSUME_NONNULL_END
