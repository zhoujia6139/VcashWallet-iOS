//
//  ProgressView.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/6/14.
//  Copyright © 2019 blockin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^RestoreSuccessCallBack)(void);

@interface ProgressView : UIView

@property (nonatomic, copy) RestoreSuccessCallBack restoreSuccessCallBack;

@property (nonatomic, assign) float progress;

- (void)show;

@end

NS_ASSUME_NONNULL_END
