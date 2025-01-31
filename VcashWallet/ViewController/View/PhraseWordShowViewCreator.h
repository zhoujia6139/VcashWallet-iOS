//
//  PhraseWordShowViewCreator.h
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/3.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kPastePhrase @"kPastePhrase"

@interface PhraseWordShowViewCreator : NSObject<UITextFieldDelegate>

typedef void (^PhraseWordViewCallback)(CGFloat height,NSInteger wordsCount);

typedef void (^PhraseWordFillAllCallBack)(NSString *title);


-(void)creatPhraseViewWithParentView:(UIView*)view isCanEdit:(BOOL)yesOrNo mnemonicArr:(NSArray *)mnemonicArr withCallBack:(PhraseWordViewCallback)callback;

- (void)creatPhraseViewWithParentView:(UIView*)view vc:(UIViewController *)vc needConfirmPhraseArr:(NSArray *)needConfirmPhraseArr dicData:(NSDictionary *)dicData  withCallBack:(PhraseWordFillAllCallBack)callback;

-(NSArray*)getAllInputWords;

- (void)setInputWordsArray:(NSArray*)wordsArr;

- (void)firstTextFieldBecomeFirstResponder;


@end

typedef void(^ClickPhraseCallBack)(NSInteger index);
typedef void(^DidEndEditingCallBack)(void);

#import "ContainWordView.h"

@interface PhraseWordItemView:UIView

@property (nonatomic, strong) NSString *phrase;

@property (nonatomic, strong) UIColor *tagColor;

@property (nonatomic, assign) BOOL textFieldEnble;

@property (nonatomic, strong) UIColor *textFieldColor;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, copy) ClickPhraseCallBack clickPhraseCallBack;

@property (nonatomic, copy) DidEndEditingCallBack didEndEditingCallBack;


@end
