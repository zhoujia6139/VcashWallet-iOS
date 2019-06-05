//
//  LockScreenSetViewController.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/6/3.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN



@interface LockScreenSetViewController : BaseViewController

@end

@class LockScreenSetItemView;

typedef void(^ChoseLockScreenTypeCallBack)(LockScreenType lockScreenType,LockScreenSetItemView *item);

@interface LockScreenSetItemView : UIView

@property (nonatomic,  strong) NSString *title;

@property (nonatomic,  assign) BOOL isSeleted;

@property (nonatomic,  assign) LockScreenType lockScreenType;

@property (nonatomic, copy)ChoseLockScreenTypeCallBack choseLockScreenTypeCallBack;

@end

NS_ASSUME_NONNULL_END
