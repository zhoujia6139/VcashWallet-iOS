//
//  VcashTokenInfo.h
//  VcashWallet
//
//  Created by jia zhou on 2020/1/13.
//  Copyright © 2020年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VcashTokenInfo : NSObject<NSCoding>

@property (strong, nonatomic)NSString* TokenId;

@property (strong, nonatomic)NSString* Name;

@property (strong, nonatomic)NSString* FullName;

@property (strong, nonatomic)NSString* BriefInfo;

@property (strong, nonatomic)NSString* DetailInfoUrl;

@property (strong, nonatomic)NSString* IconName;

@end

NS_ASSUME_NONNULL_END
