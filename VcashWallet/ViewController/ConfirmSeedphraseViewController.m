//
//  ConfirmSeedphraseViewController.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/22.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "ConfirmSeedphraseViewController.h"
#import "PhraseWordShowViewCreator.h"
#import "PinPasswordSetViewController.h"
#import "AlertView.h"

@interface ConfirmSeedphraseViewController ()

@property (weak, nonatomic) IBOutlet UIView *promptView;

@property (weak, nonatomic) IBOutlet UIView *needConfirmPhraseView;

@property (weak, nonatomic) IBOutlet UIView *chosePhraseView;

@property (nonatomic, strong) NSArray *confirmPhraseArr;

@property (nonatomic, strong) NSArray *needConfirmPhraseArr;

@property (nonatomic, strong) NSMutableDictionary *dic;

@property (nonatomic, strong) NSMutableArray *phraseArr;

@property (nonatomic, strong) NSMutableSet *mutableBtnSet;


@property (weak, nonatomic) IBOutlet UIButton *btnCheck;

@end

@implementation ConfirmSeedphraseViewController{
    PhraseWordShowViewCreator  *creator;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _confirmPhraseArr = [self randomConfirmPhraseArr];
    
    _needConfirmPhraseArr = [self getNeedConfimPhraseArray:self.confirmPhraseArr];
    
    _dic = [NSMutableDictionary dictionary];
    NSMutableArray *indexArr = [NSMutableArray array];
    
    for (NSString *str in self.needConfirmPhraseArr) {
        NSInteger index = [self.mnemonicWordsArr indexOfObject:str];
        [indexArr addObject:@(index)];
        [self.dic setObject:@(index) forKey:str];
    }
    _phraseArr = [NSMutableArray array];
    _mutableBtnSet = [[NSMutableSet alloc] init];
    [self configView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self addObserver:self forKeyPath:@"phraseArr" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self removeObserver:self forKeyPath:@"phraseArr"];
}

- (void)configView{
    self.title = [LanguageService contentForKey:@"confirmSeedPhrase"];
    ViewRadius(self.promptView, 4.0);
    ViewRadius(self.btnCheck, 4.0);
    self.btnCheck.userInteractionEnabled = NO;
    [self.btnCheck setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnCheck setBackgroundImage:[UIImage imageWithColor:COrangeEnableColor] forState:UIControlStateNormal];
    creator = [PhraseWordShowViewCreator new];
    [creator creatPhraseViewWithParentView:self.needConfirmPhraseView vc:self needConfirmPhraseArr:self.needConfirmPhraseArr dicData:self.dic  withCallBack:nil];
    
    CGFloat itemWidth = (ScreenWidth - 80 - 18) / 3;
    CGFloat itemHeight = 45.0;
    UIButton *priBtn = nil;
    for (NSInteger i = 0; i < self.confirmPhraseArr.count; i++) {
        int row = i % 3;
        UIButton *btn = [[UIButton alloc] init];
        ViewBorderRadius(btn, 4.0, 1, CLineColor);
        [btn addTarget:self action:@selector(chose:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [btn setTitle:self.confirmPhraseArr[i] forState:UIControlStateNormal];
        btn.tag = 100 + i;
        [self.chosePhraseView addSubview:btn];
        if (!priBtn) {
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.chosePhraseView).offset(40);
                make.top.equalTo(self.chosePhraseView);
                make.width.mas_equalTo(itemWidth);
                make.height.mas_equalTo(itemHeight);
            }];
        }else{
            if (row != 0) {
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(priBtn.mas_right).offset(9);
                    make.top.equalTo(priBtn);
                    make.width.mas_equalTo(itemWidth);
                    make.height.mas_equalTo(itemHeight);
                }];
            }else{
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.chosePhraseView).offset(40);
                    make.top.equalTo(priBtn.mas_bottom).offset(10);
                    make.width.mas_equalTo(itemWidth);
                    make.height.mas_equalTo(itemHeight);
                }];
            }
            
        }
        priBtn = btn;
    }
    
   
}

- (void)backBtnClicked{
    AlertView *alterView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([AlertView class]) owner:nil options:nil] firstObject];
    __weak typeof(self) weakSelf = self;
    alterView.doneCallBack = ^{
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.navigationController popViewControllerAnimated:YES];
    };
    alterView.title = [LanguageService contentForKey:@"confirmBackTitle"];
    alterView.msg = [LanguageService contentForKey:@"confirmBackMsg"];
    alterView.doneTitle = [LanguageService contentForKey:@"doneTitle"];
    [alterView show];
}

- (void)chose:(UIButton *)btn{
    [self.mutableBtnSet addObject:btn];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    ViewBorderRadius(btn, 4, 0, CLineColor);
    NSInteger index = btn.tag - 100;
    NSString *phrase = self.confirmPhraseArr[index];
    if ([self.phraseArr containsObject:phrase]) {
        return ;
    }
    [[self mutableArrayValueForKeyPath:@"phraseArr"] addObject:phrase];
    [creator creatPhraseViewWithParentView:self.needConfirmPhraseView vc:self needConfirmPhraseArr:self.needConfirmPhraseArr dicData:self.dic  withCallBack:^(NSString *title) {
        for (UIButton *btn in self.mutableBtnSet) {
            if ([btn.currentTitle isEqualToString:title]) {
                [btn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
                btn.backgroundColor = [UIColor whiteColor];
                ViewBorderRadius(btn, 4, 1, CLineColor);
            }
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"phraseArr"]) {
        if (self.phraseArr.count < 6) {
            self.btnCheck.userInteractionEnabled = NO;
            [self.btnCheck setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.btnCheck setBackgroundImage:[UIImage imageWithColor:COrangeEnableColor] forState:UIControlStateNormal];
        }else{
            self.btnCheck.userInteractionEnabled = YES;
            [self.btnCheck setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.btnCheck setBackgroundImage:[UIImage imageWithColor:COrangeColor] forState:UIControlStateNormal];
        }
    }
}

- (IBAction)clickedCheck:(id)sender {
    if (self.needConfirmPhraseArr.count == self.phraseArr.count) {
        NSInteger count = self.needConfirmPhraseArr.count;
        BOOL same = YES;
        for (NSInteger i = 0; i < count; i++) {
            if (![self.needConfirmPhraseArr[i] isEqualToString:self.phraseArr[i]]) {
                same = NO;
                break;
            }
        }
        if (!same) {
            [self.view makeToast:[LanguageService contentForKey:@"wordInconsistent"]];
            [[self mutableArrayValueForKeyPath:@"phraseArr"] removeAllObjects];
            for (UIButton *btn in self.mutableBtnSet) {
                [btn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
                btn.backgroundColor = [UIColor whiteColor];
                ViewBorderRadius(btn, 4, 1, CLineColor);
            }
            [self.mutableBtnSet removeAllObjects];
            [creator creatPhraseViewWithParentView:self.needConfirmPhraseView vc:self needConfirmPhraseArr:self.needConfirmPhraseArr dicData:self.dic  withCallBack:^(NSString *title) {
                
            }];
            
            return;
        }
        PinPasswordSetViewController *passwordSetVc = [[PinPasswordSetViewController alloc] init];
        passwordSetVc.mnemonicWordsArr = self.mnemonicWordsArr;
        [self.navigationController pushViewController:passwordSetVc animated:YES];
    }
}


- (NSArray *)randomConfirmPhraseArr{
    NSArray *array = self.mnemonicWordsArr;
    NSMutableSet *randomSet = [[NSMutableSet alloc] init];
    while ([randomSet count] < 6) {
        int r = arc4random() % [array count];
        [randomSet addObject:[array objectAtIndex:r]];
    }
    NSArray *randomArray = [randomSet allObjects];
    return randomArray;
}

- (NSArray *)getNeedConfimPhraseArray:(NSArray *)arr{
    arr = [arr sortedArrayUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
        int seed = arc4random_uniform(2);
        if (seed) {
            return [str1 compare:str2];
        } else {
            return [str2 compare:str1];
        }
    }];
    return arr;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

@implementation ChosePhraseItemView{
    UIButton * phraseBtn;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        phraseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [phraseBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        phraseBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:phraseBtn];
        [phraseBtn addTarget:self action:@selector(chosePhrase:) forControlEvents:UIControlEventTouchUpInside];
        [phraseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

+ (UIView *)creatPhraseViewWithParentView:(UIView *)view phraseArr:(NSArray *)phraseArr choseCallBack:(ChosePhraseCallBack)choseCallBack{
    ChosePhraseItemView *priItemView;
    CGFloat itemWidth = (ScreenWidth - 100 - 30) / 3;
    CGFloat itemHeight = 45.0;
    for (NSInteger i = 0; i < phraseArr.count; i++) {
        int row = i % 3;
        ChosePhraseItemView *itemView = [[ChosePhraseItemView alloc] init];
        itemView.chosePhraseCallBack = choseCallBack;
        ViewBorderRadius(itemView, 4.0, 1, CLineColor);
        itemView.title = phraseArr[i];
        itemView.tag = 100 + i;
        [view addSubview:itemView];
        if (!priItemView) {
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(view).offset(50);
                make.top.equalTo(view);
                make.width.mas_equalTo(itemWidth);
                make.height.mas_equalTo(itemHeight);
            }];
        }else{
            if (row != 0) {
                [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(priItemView.mas_right).offset(15);
                    make.top.equalTo(priItemView);
                    make.width.mas_equalTo(itemWidth);
                    make.height.mas_equalTo(itemHeight);
                }];
            }else{
                [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(view).offset(50);
                    make.top.equalTo(priItemView.mas_bottom).offset(15);
                    make.width.mas_equalTo(itemWidth);
                    make.height.mas_equalTo(itemHeight);
                }];
            }
            
        }
        priItemView = itemView;
    }
    return view;
}

- (void)setTitle:(NSString *)title{
    if (!title) {
        return;
    }
    [phraseBtn setTitle:title forState:UIControlStateNormal];
}

- (void)chosePhrase:(UIButton *)btn{
    NSInteger index = self.tag - 100;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor colorWithHexString:@"#999999"];
    if (self.chosePhraseCallBack) {
        self.chosePhraseCallBack(index);
    }
}

@end
