//
//  AlertView.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/22.
//  Copyright © 2019 blockin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DoneCallBack)(void);

@interface AlertView : UIView

@property (nonatomic, copy) DoneCallBack doneCallBack;

- (void)show;


@end

NS_ASSUME_NONNULL_END
