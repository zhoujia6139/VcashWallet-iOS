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

@interface ConfirmSeedphraseViewController ()

@property (weak, nonatomic) IBOutlet UIView *promptView;

@property (weak, nonatomic) IBOutlet UIView *needConfirmPhraseView;

@property (weak, nonatomic) IBOutlet UIView *chosePhraseView;

@property (nonatomic, strong) NSArray *confirmPhraseArr;

@property (nonatomic, strong) NSArray *needConfirmPhraseArr;

@property (nonatomic, strong) NSMutableDictionary *dic;

@end

@implementation ConfirmSeedphraseViewController{
    
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
    
    [self configView];
}

- (void)configView{
    ViewRadius(self.promptView, 4.0);
    [AppHelper addLineTopWithParentView:self.chosePhraseView];
   PhraseWordShowViewCreator  *creator = [PhraseWordShowViewCreator new];
    [creator creatPhraseViewWithParentView:self.needConfirmPhraseView needConfirmPhraseArr:self.needConfirmPhraseArr dicData:self.dic arrPhrase:nil withCallBack:nil];
    __weak typeof(self) weakSelf = self;
    NSMutableArray *phraseArr = [NSMutableArray array];
    [ChosePhraseItemView creatPhraseViewWithParentView:self.chosePhraseView phraseArr:self.confirmPhraseArr choseCallBack:^(NSInteger index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSString *phrase = strongSelf.confirmPhraseArr[index];
        if ([phraseArr containsObject:phrase]) {
            return ;
        }
        [phraseArr addObject:phrase];
        [creator creatPhraseViewWithParentView:strongSelf.needConfirmPhraseView needConfirmPhraseArr:strongSelf.needConfirmPhraseArr dicData:strongSelf.dic arrPhrase:phraseArr withCallBack:^(BOOL isAllRight) {
            if (isAllRight) {
                PinPasswordSetViewController*vc = [PinPasswordSetViewController new];
                vc.mnemonicWordsArr = strongSelf.mnemonicWordsArr;
                [strongSelf.navigationController pushViewController:vc animated:YES];
            }else{
                PinPasswordSetViewController*vc = [PinPasswordSetViewController new];
                vc.mnemonicWordsArr = strongSelf.mnemonicWordsArr;
                [strongSelf.navigationController pushViewController:vc animated:YES];
            }
        }];
        
    }];
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
        [AppHelper addLineWithParentView:self];
        [AppHelper addLineRightWithParentView:self];
    }
    return self;
}

+ (UIView *)creatPhraseViewWithParentView:(UIView *)view phraseArr:(NSArray *)phraseArr choseCallBack:(ChosePhraseCallBack)choseCallBack{
    ChosePhraseItemView *priItemView;
    CGFloat itemWidth = ScreenWidth / 3.0;
    CGFloat itemHeight = 45.0;
    for (NSInteger i = 0; i < phraseArr.count; i++) {
        int row = i % 3;
        ChosePhraseItemView *itemView = [[ChosePhraseItemView alloc] init];
        itemView.chosePhraseCallBack = choseCallBack;
        itemView.title = phraseArr[i];
        itemView.tag = 100 + i;
        [view addSubview:itemView];
        if (!priItemView) {
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(view);
                make.top.equalTo(view);
                make.width.mas_equalTo(itemWidth);
                make.height.mas_equalTo(itemHeight);
            }];
        }else{
            if (row != 0) {
                [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(priItemView.mas_right);
                    make.top.equalTo(priItemView);
                    make.width.mas_equalTo(itemWidth);
                    make.height.mas_equalTo(itemHeight);
                }];
            }else{
                [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(view);
                    make.top.equalTo(priItemView.mas_bottom);
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
    if (self.chosePhraseCallBack) {
        self.chosePhraseCallBack(index);
    }
}

@end
