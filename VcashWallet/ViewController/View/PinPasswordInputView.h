//
//  PinPasswordInputView.h
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/16.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PinPasswordInputView;

@protocol PasswordViewDelegate <NSObject>

-(void)PinPasswordView:(PinPasswordInputView*)inputview didGetPassword:(NSString*)password;

@end

@interface PinPasswordInputView : UIView<UITextFieldDelegate>

@property (nonatomic, weak, nullable) id <PasswordViewDelegate> delegate;

- (void)clearUpPassword;

-(NSString*)getInput;

-(void)openKeyboard;

@end

