//
//  LeftMenuModel.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/23.
//  Copyright © 2019 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LeftMenuModel : NSObject

@property (nonatomic, strong) NSString *imageName;

@property (nonatomic, strong) NSString *imageHightName;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, assign) BOOL selected;


@end

NS_ASSUME_NONNULL_END
