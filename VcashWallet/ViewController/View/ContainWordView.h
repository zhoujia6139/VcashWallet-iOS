//
//  ContainWordView.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/7/19.
//  Copyright © 2019 blockin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SeletedWordCallBack)(NSString *word);

@interface ContainWordView : UIView

@property (nonatomic, copy) SeletedWordCallBack seletedWordCallBack;


- (instancetype)initWithArrData:(NSArray *)arrData;

- (void)updateDataWith:(NSArray *)arrData;

- (void)removeViewFromSuperview;

- (void)show;

@end

NS_ASSUME_NONNULL_END
