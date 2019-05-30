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
#define kWordItemViewWidth ((ScreenWidth - 24)/3.0)
#define kWordItemViewHeight 45
#define kWordItemTagStart 1000
#define kWordItemTagEnd 1011

@implementation PhraseWordShowViewCreator
{
    UIView* mParentView;
    NSArray* allWords;
}

-(void)creatPhraseViewWithParentView:(UIView*)view isCanEdit:(BOOL)yesOrNo withCallBack:(PhraseWordViewCallback)callback
{
    CGFloat parentHeight = 4*kWordItemViewHeight;
    for (int i=0; i<kWordItemCount; i++)
    {
        int line = i/3;
        int row = i%3;
        PhraseWordItemView *itemView = [[PhraseWordItemView alloc] init];
        itemView.didEndEditingCallBack = ^{
          NSInteger inputCount =  [[self getAllInputWords] count];
            if (callback) {
                callback(parentHeight,inputCount);
            }
        };
        itemView.tag = (kWordItemTagStart + i);
        itemView.index = i;
        itemView.userInteractionEnabled = yesOrNo;
        itemView.textFieldEnble = yesOrNo;
//        itemView.textAlignment = NSTextAlignmentCenter;
//        itemView.delegate = self;
//        itemView.keyboardType = UIKeyboardTypeNamePhonePad;
//        itemView.autocapitalizationType = UITextAutocapitalizationTypeNone;
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
    
    ViewBorderRadius(view, 4.0, VLineWidth, CLineColor);
    mParentView = view;
    
    
    if (callback)
    {
        callback(parentHeight,0);
    }
}

- (void)creatPhraseViewWithParentView:(UIView*)view needConfirmPhraseArr:(NSArray *)needConfirmPhraseArr dicData:(NSDictionary *)dicData arrPhrase:(NSMutableArray *)arrPhrase withCallBack:(PhraseWordFillAllCallBack)callback{
    [view removeAllSubviews];
    NSInteger itemCount = needConfirmPhraseArr.count;
//    CGFloat parentHeight = 4*kWordItemViewHeight;
    NSMutableArray *arrFill = [NSMutableArray array];
    for (int i=0; i<itemCount; i++)
    {
        NSString *key = needConfirmPhraseArr[i];
        int line = i/3;
        int row = i%3;
        PhraseWordItemView *itemView = [[PhraseWordItemView alloc] init];
        itemView.clickPhraseCallBack = ^(NSInteger index) {
            if ([[dicData objectForKey:itemView.phrase] integerValue] == itemView.index) {
                return ;
            }
            if (index < arrPhrase.count) {
                [arrPhrase removeObjectAtIndex:index];
            }
             [view removeAllSubviews];
            [self creatPhraseViewWithParentView:view needConfirmPhraseArr:needConfirmPhraseArr dicData:dicData arrPhrase:arrPhrase withCallBack:callback];
        };
        itemView.tag = (kWordItemTagStart + i);
        itemView.textFieldEnble = NO;
        itemView.index = [[dicData objectForKey:key] integerValue];
        itemView.tagColor = [UIColor colorWithRed:236 / 255.0 green:235 / 255.0 blue:235 / 255.0 alpha:1];
        if (i < arrPhrase.count) {
            itemView.phrase = arrPhrase[i];
            BOOL fillRight = ([[dicData objectForKey:itemView.phrase] integerValue] == itemView.index);
            [arrFill addObject:@(fillRight)];
            itemView.tagColor =  fillRight ? [UIColor colorWithHexString:@"#66CC33"] : [UIColor colorWithHexString:@"#FF3333"];
        }
      
        [view addSubview:itemView];
        int top = line*kWordItemViewHeight;
        int left = row*kWordItemViewWidth;
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(view).offset(top);
            make.left.mas_equalTo(view).offset(left);
            make.width.mas_equalTo(kWordItemViewWidth);
            make.height.mas_equalTo(kWordItemViewHeight);
        }];
    }
    
    ViewBorderRadius(view, 4.0, VLineWidth, CLineColor);
    mParentView = view;
    if (arrPhrase.count == 6) {
        BOOL isAllRight = YES;
        for (NSNumber *num in arrFill) {
            if ([num integerValue] == 0) {
                isAllRight = NO;
                break;
            }
        }
        if (callback)
        {
            callback(isAllRight);
        }
    }
    
    
}

-(NSArray*)getAllInputWords
{
    NSMutableArray* wordsArr = [NSMutableArray new];
    for (NSUInteger i=0; i<kWordItemCount; i++)
    {
        PhraseWordItemView* field = [mParentView viewWithTag:(kWordItemTagStart+i)];
        if ([self checkWordIsValid:field.phrase])
        {
            NSString *phrase = [field.phrase  lowercaseString];
            [wordsArr addObject:phrase];
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
            PhraseWordItemView* field = [mParentView viewWithTag:(kWordItemTagStart+i)];
            field.phrase = word;
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
    if (!allWords) {
         allWords = [WalletWrapper getAllPhraseWords];
    }
    word = [word lowercaseString];
    return ([allWords containsObject:word]);
}

@end





@interface PhraseWordItemView ()<UITextFieldDelegate>

@property (nonatomic, strong) UIButton *clickBtn;

@property (nonatomic, strong) UIButton *tagBtn;

@property (nonatomic, strong) UITextField *textField;



@end

@implementation PhraseWordItemView{
    NSArray *allWords;
}

@synthesize phrase = _phrase;


- (instancetype)init{
    self = [super init];
    if (self) {
        _clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_clickBtn];
        [_clickBtn addTarget:self action:@selector(clickPhrase:) forControlEvents:UIControlEventTouchUpInside];
        [_clickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        _tagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _tagBtn.userInteractionEnabled = NO;
        _tagBtn.backgroundColor = [UIColor colorWithRed:236 / 255.0 green:235 / 255.0 blue:235 / 255.0 alpha:1];
        _tagBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        ViewRadius(_tagBtn, 9.0);
        [self addSubview:_tagBtn];
        [_tagBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(18);
            make.centerY.equalTo(self);
            make.width.height.mas_equalTo(18);
        }];
        
        _textField = [[UITextField alloc] init];
        _textField.textColor = [UIColor darkTextColor];
        _textField.font = [UIFont systemFontOfSize:15];
        _textField.delegate = self;
        [_textField addTarget:self action:@selector(enterPhrase:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:_textField];
        [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.tagBtn.mas_right).offset(8);
            make.right.equalTo(self);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(16);
        }];
//        self.layer.borderWidth = 1;
//        self.layer.borderColor = [UIColorFromRGB(0xcccccc) CGColor];
        
        [AppHelper addLineWithParentView:self];
        [AppHelper addLineRightWithParentView:self];
    }
    return self;
}

- (BOOL)checkWordIsValid:(NSString*)word{
    if (!allWords) {
        allWords = [WalletWrapper getAllPhraseWords];
    }
    word = [word lowercaseString];
    return ([allWords containsObject:word]);
}

- (void)enterPhrase:(UITextField *)textField{
    _phrase = textField.text;
    if (textField.text.length == 0) {
        self.textField.textColor = [UIColor darkTextColor];
        self.tagBtn.backgroundColor = [UIColor colorWithRed:236 / 255.0 green:235 / 255.0 blue:235 / 255.0 alpha:1];
        return;
    }
    self.tagColor = [self checkWordIsValid:textField.text] ?  [UIColor colorWithHexString:@"#66CC33"] : [UIColor colorWithHexString:@"#FF3333"];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (self.didEndEditingCallBack) {
        self.didEndEditingCallBack();
    }
}


- (void)setTextFieldEnble:(BOOL)textFieldEnble{
    self.textField.userInteractionEnabled = textFieldEnble;
}

- (NSString *)phrase{
    return self.textField.text;
}

- (void)setPhrase:(NSString *)phrase{
    _phrase = phrase;
    self.textField.text = phrase;
}

- (NSString *)text{
    return _textField.text;
}



- (void)setText:(NSString *)text{
    self.textField.text = text;
}

- (void)setIndex:(NSInteger)index{
    _index = index;
    [self.tagBtn setTitle:[NSString stringWithFormat:@"%ld",(long)index + 1] forState:UIControlStateNormal];
}

- (void)setTagColor:(UIColor *)tagColor{
    self.tagBtn.backgroundColor = tagColor;
    self.textField.textColor = tagColor;
}

- (void)clickPhrase:(UIButton *)btn{
    if (self.clickPhraseCallBack) {
        NSInteger index = self.tag - kWordItemTagStart;
        self.clickPhraseCallBack(index);
    }
}

//-(instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self)
//    {
//       
//    }
//    
//    return self;
//}

@end
