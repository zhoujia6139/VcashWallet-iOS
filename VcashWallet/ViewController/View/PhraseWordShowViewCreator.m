//
//  PhraseWordShowViewCreator.m
//  PoolinWallet
//
//  Created by jia zhou on 2018/8/3.
//  Copyright © 2018年 blockin. All rights reserved.
//

#import "PhraseWordShowViewCreator.h"
#import "WalletWrapper.h"

#define kWordItemCount 24
#define kWordItemViewWidth (ScreenWidth/3)
#define kWordItemViewHeight 50
#define kWordItemTagStart 1000
#define kWordItemTagEnd 1011

@implementation PhraseWordShowViewCreator
{
    UIView* mParentView;
}

-(void)creatPhraseViewWithParentView:(UIView*)view isCanEdit:(BOOL)yesOrNo withCallBack:(PhraseWordViewCallback)callback
{
    CGFloat parentHeight = 4*kWordItemViewHeight;
    for (int i=0; i<kWordItemCount; i++)
    {
        int line = i/3;
        int row = i%3;
        PhraseWordItemView *itemView = [PhraseWordItemView new];
        itemView.textAlignment = NSTextAlignmentCenter;
        itemView.tag = (kWordItemTagStart + i);
        itemView.userInteractionEnabled = yesOrNo;
        itemView.delegate = self;
        itemView.keyboardType = UIKeyboardTypeNamePhonePad;
        itemView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [view addSubview:itemView];
        int top = line*kWordItemViewHeight;
        int left = row*kWordItemViewWidth;
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(view).offset(top);
            make.left.mas_equalTo(view).offset(left);
            make.width.mas_equalTo(kWordItemViewWidth);
            make.height.mas_equalTo(kWordItemViewHeight);
        }];
//        [itemView setThreshold:[arr objectAtIndex:i] andCoinType:self.coinType];
//        [itemView addTarget:self action:@selector(ItemViewGetClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    mParentView = view;
    
    if (callback)
    {
        callback(parentHeight);
    }
}

-(NSArray*)getAllInputWords
{
    NSMutableArray* wordsArr = [NSMutableArray new];
    for (NSUInteger i=0; i<kWordItemCount; i++)
    {
        UITextField* field = [mParentView viewWithTag:(kWordItemTagStart+i)];
        if ([self checkWordIsValid:field.text])
        {
            [wordsArr addObject:field.text];
        }
    }
    
//    if (wordsArr.count == kWordItemCount)
//    {
        return wordsArr;
//    }
//    else
//    {
//        return nil;
//    }
}

-(void)setInputWordsArray:(NSArray*)wordsArr
{
    if (wordsArr.count == kWordItemCount)
    {
        for (NSUInteger i=0; i<kWordItemCount; i++)
        {
            NSString* word = [wordsArr objectAtIndex:i];
            UITextField* field = [mParentView viewWithTag:(kWordItemTagStart+i)];
            field.text = word;
        }
    }
}

#pragma mark delegate
//- (void)textFieldDidEndEditing:(UITextField *)textField;
//{
//    NSInteger nextTag = textField.tag + 1;
//    if (nextTag <= kWordItemTagEnd)
//    {
//        UITextField* nextInput = [mParentView viewWithTag:nextTag];
//        [nextInput becomeFirstResponder];
//    }
//
//}
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    return [self checkWordIsValid:textField.text];
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self checkWordIsValid:textField.text])
    {
        NSInteger nextTag = textField.tag + 1;
        if (nextTag <= kWordItemTagEnd)
        {
            UITextField* nextInput = [mParentView viewWithTag:nextTag];
            [nextInput becomeFirstResponder];
        }
        return YES;
    }
    [MBHudHelper showTextTips:@"请输入有效的词语" onView:nil withDuration:1.5];
    return NO;
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    if (string.length == 0 && textField.text.length == 0)
//    {
//        NSInteger lastTag = textField.tag - 1;
//        if (lastTag >= kWordItemTagStart)
//        {
//            UITextField* lastInput = [mParentView viewWithTag:lastTag];
//            [lastInput becomeFirstResponder];
//        }
//    }
//    return YES;
//}

#pragma mark private

-(BOOL)checkWordIsValid:(NSString*)word
{
    NSArray* allWords = [WalletWrapper getAllPhraseWords];
    return ([allWords containsObject:word]);
}

@end


@implementation PhraseWordItemView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColorFromRGB(0xcccccc) CGColor];
    }
    
    return self;
}

@end
