//
//  LeftMenuManager.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/6/10.
//  Copyright © 2019 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeftMenuView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LeftMenuManager : NSObject

@property (nonatomic, strong) LeftMenuView *leftMenuView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

+ (id)shareInstance;

- (void)addInView;

- (void)removeGestures;

- (void)addGestures;

@end

NS_ASSUME_NONNULL_END
