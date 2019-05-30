//
//  MessageNotificationView.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/27.
//  Copyright © 2019 blockin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ServerTransaction;

@interface MessageNotificationView : UIView

@property (nonatomic, strong) ServerTransaction *serverTx;

@property (nonatomic, strong) NSString *message;



- (void)show;


@end

NS_ASSUME_NONNULL_END
