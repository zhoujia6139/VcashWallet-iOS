//
//  PhraseWordShowViewCreator.h
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/3.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhraseWordShowViewCreator : NSObject<UITextFieldDelegate>

typedef void (^PhraseWordViewCallback)(CGFloat height,NSInteger wordsCount);

typedef void (^PhraseWordFillAllCallBack)(BOOL);

-(void)creatPhraseViewWithParentView:(UIView*)view isCanEdit:(BOOL)yesOrNo withCallBack:(PhraseWordViewCallback)callback;

- (void)creatPhraseViewWithParentView:(UIView*)view needConfirmPhraseArr:(NSArray *)needConfirmPhraseArr dicData:(NSDictionary *)dicData arrPhrase:(NSMutableArray *)arrPhrase withCallBack:(PhraseWordFillAllCallBack)callback;

-(NSArray*)getAllInputWords;

-(void)setInputWordsArray:(NSArray*)wordsArr;

@end

typedef void(^ClickPhraseCallBack)(NSInteger index);
typedef void(^DidEndEditingCallBack)(void);

@interface PhraseWordItemView:UIView

@property (nonatomic, strong) NSString *phrase;

@property (nonatomic, strong) UIColor *tagColor;

@property (nonatomic, assign) BOOL textFieldEnble;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, copy) ClickPhraseCallBack clickPhraseCallBack;

@property (nonatomic, copy) DidEndEditingCallBack didEndEditingCallBack;


@end
