//
//  LanguageManager.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/22.
//  Copyright © 2019 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define LanguageService [LanguageManager shareInstance]

@interface LanguageManager : NSObject

+ (id) shareInstance;

- (NSString *)contentForKey:(NSString *)key;


@end

NS_ASSUME_NONNULL_END
