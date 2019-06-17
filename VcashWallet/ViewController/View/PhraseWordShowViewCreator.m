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
    
    
    if (callback)
    {
        callback(parentHeight,0);
    }
}

- (void)firstTextFieldBecomeFirstResponder{
   PhraseWordItemView *itemView = [mParentView viewWithTag:kWordItemTagStart];
    for (id  iv in itemView.subviews) {
        if ([iv isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)iv;
            [textField becomeFirstResponder];
            break;
        }
    }
}

- (void)creatPhraseViewWithParentView:(UIView*)view vc:(UIViewController *)vc needConfirmPhraseArr:(NSArray *)needConfirmPhraseArr dicData:(NSDictionary *)dicData  withCallBack:(PhraseWordFillAllCallBack)callback{
    [view removeAllSubviews];
    NSInteger itemCount = needConfirmPhraseArr.count;
    for (int i=0; i<itemCount; i++)
    {
        NSString *key = needConfirmPhraseArr[i];
        int line = i/3;
        int row = i%3;
        PhraseWordItemView *itemView = [[PhraseWordItemView alloc] init];
        if (i == [vc mutableArrayValueForKeyPath:@"phraseArr"].count) {
            UIView *cursorView = [[UIView alloc] init];
            cursorView.backgroundColor = [UIColor colorWithHexString:@"#1A181C"];
            [itemView addSubview:cursorView];
            [cursorView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(itemView).offset(45);
                make.centerY.equalTo(itemView);
                make.width.mas_equalTo(1);
                make.height.mas_equalTo(18);
            }];
        }
        
        itemView.clickPhraseCallBack = ^(NSInteger index) {
            if (index < [vc mutableArrayValueForKeyPath:@"phraseArr"].count) {
                NSString *title = [[vc mutableArrayValueForKeyPath:@"phraseArr"] objectAtIndex:index];
                if (callback) {
                     callback(title);
                }
                [[vc mutableArrayValueForKeyPath:@"phraseArr"] removeObjectAtIndex:index];
            }else{
                return;
            }
             [view removeAllSubviews];
            [self creatPhraseViewWithParentView:view vc:vc needConfirmPhraseArr:needConfirmPhraseArr dicData:dicData  withCallBack:callback];
        };
        itemView.tag = (kWordItemTagStart + i);
        itemView.textFieldEnble = NO;
        itemView.index = [[dicData objectForKey:key] integerValue];
        itemView.tagColor = [UIColor colorWithHexString:@"#AEAEAE"];
        itemView.textFieldColor = [UIColor darkTextColor];
        if (i < [vc mutableArrayValueForKeyPath:@"phraseArr"].count) {
            itemView.phrase = [vc mutableArrayValueForKeyPath:@"phraseArr"][i];
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
    
    return wordsArr;
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
        _tagBtn.backgroundColor =  [UIColor colorWithRed:194 / 255.0 green:194 / 255.0 blue:194 / 255.0 alpha:1];
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
        _textField.returnKeyType = UIReturnKeyNext;
        [self addSubview:_textField];
        [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.tagBtn.mas_right).offset(8);
            make.right.equalTo(self);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(16);
        }];
        
        [AppHelper addLineWithParentView:self];
        [AppHelper addLineRightWithParentView:self];
        __weak typeof(self) weakSelf = self;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.textField.userInteractionEnabled) {
                [strongSelf.textField becomeFirstResponder];
            }
        }];
        [self addGestureRecognizer:tap];
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
   
    if (textField.text.length == 0) {
        self.textField.textColor = [UIColor darkTextColor];
        self.tagBtn.backgroundColor = [UIColor colorWithRed:194 / 255.0 green:194 / 255.0 blue:194 / 255.0 alpha:1];
        return;
    }
    textField.text = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
     _phrase = textField.text;
    self.tagColor = [self checkWordIsValid:textField.text] ?  [UIColor colorWithHexString:@"#66CC33"] : [UIColor colorWithHexString:@"#FF3333"];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (self.didEndEditingCallBack) {
        self.didEndEditingCallBack();
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSMutableArray *arr = [NSMutableArray array];
    for (PhraseWordItemView *iv in [[self superview] subviews]) {
        for (id subIv in iv.subviews) {
            if ([subIv isKindOfClass:[UITextField class]]) {
                [arr addObject:subIv];
            }
        }
    }
    NSInteger index = [arr indexOfObject:textField];
    if (index + 1 < arr.count) {
        UITextField *nextField = [arr objectAtIndex:index + 1];
        [nextField becomeFirstResponder];
    }
    return NO;
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

- (void)setTextFieldColor:(UIColor *)textFieldColor{
    self.textField.textColor = textFieldColor;
}

- (void)clickPhrase:(UIButton *)btn{
    if (self.textField.userInteractionEnabled) {
        [self.textField becomeFirstResponder];
    }
    if (self.clickPhraseCallBack) {
        NSInteger index = self.tag - kWordItemTagStart;
        self.clickPhraseCallBack(index);
    }
}



@end
