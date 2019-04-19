//
//  PhraseWordShowViewCreator.h
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/3.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhraseWordShowViewCreator : NSObject<UITextFieldDelegate>

typedef void (^PhraseWordViewCallback)(CGFloat);

-(void)creatPhraseViewWithParentView:(UIView*)view isCanEdit:(BOOL)yesOrNo withCallBack:(PhraseWordViewCallback)callback;

-(NSArray*)getAllInputWords;

-(void)setInputWordsArray:(NSArray*)wordsArr;

@end


@interface PhraseWordItemView:UITextField

@end
