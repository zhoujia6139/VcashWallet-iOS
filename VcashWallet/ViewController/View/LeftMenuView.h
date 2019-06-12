//
//  LeftMenuView.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/23.
//  Copyright © 2019 blockin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LeftMenuViewDelegate <NSObject>

@optional

- (void)isHaveHidden:(BOOL)hidden;

- (void)manageCallBack;

- (void)addObserverLinkCallBack;

@end

@interface LeftMenuView : UIView

@property (nonatomic, weak) id <LeftMenuViewDelegate> delegate;

- (void)refreshData;

- (void)addInView;

- (void)addAlphaViewPanGesture:(UIPanGestureRecognizer *)pan;

- (void)showAnimation;

- (void)hiddenAnimation;



@end

NS_ASSUME_NONNULL_END
