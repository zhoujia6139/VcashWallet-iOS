//
//  LockScreenSetViewController.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/6/3.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "LockScreenSetViewController.h"
#import "LockScreenTimeService.h"


@interface LockScreenSetViewController ()

@property (nonatomic,  strong) LockScreenSetItemView *seletedItem;

@end

@implementation LockScreenSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = [LanguageService contentForKey:@"lockScreen"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *arrTitle= @[[LanguageService contentForKey:@"never"],[LanguageService contentForKey:@"after30Seconds"],[LanguageService contentForKey:@"after1Minute"],[LanguageService contentForKey:@"after3Minute"]];
    NSArray *arrLockScreenType = @[@(LockScreenTypeNever),@(LockScreenType30Seonds),@(LockScreenType1Minute),@(LockScreenType3Minutes)];
    
    LockScreenSetItemView *priItem = nil;
    LockScreenType userLockScreenType =  [[LockScreenTimeService shareInstance] readLockScreenType];
    __weak typeof(self) weakSelf = self;
    for (NSInteger i = 0; i < arrTitle.count; i++) {
        LockScreenSetItemView *item = [[LockScreenSetItemView alloc] init];
        item.tag = 100 + i;
        item.title = arrTitle[i];
        item.lockScreenType = [arrLockScreenType[i] integerValue];
        if (item.lockScreenType == userLockScreenType) {
            item.isSeleted = YES;
            self.seletedItem = item;
        }
        item.choseLockScreenTypeCallBack = ^(LockScreenType lockScreenType, LockScreenSetItemView * _Nonnull item) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.seletedItem == item) {
                return ;
            }
            strongSelf.seletedItem.isSeleted = NO;
            item.isSeleted = YES;
            strongSelf.seletedItem = item;
            [[LockScreenTimeService shareInstance] writeLockScreenType:lockScreenType];
        };
        [AppHelper addLineWithParentView:item];
        [self.view addSubview:item];
        if (!priItem) {
            [item mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view);
                make.left.right.equalTo(self.view);
                make.height.mas_equalTo(50);
            }];
            [AppHelper addLineTopWithParentView:item];
        }else{
            [item mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(priItem.mas_bottom);
                make.left.right.equalTo(self.view);
                make.height.mas_equalTo(50);
            }];
        }
        priItem = item;
    }
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


@implementation LockScreenSetItemView{
    UIButton *btn;
    UILabel *labelTitle;
    UIImageView *imageView;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [self addSubview:btn];
        [btn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#9C9D9D"]] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(choseLockScreenTime) forControlEvents:UIControlEventTouchUpInside];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        labelTitle = [[UILabel alloc] init];
        labelTitle.font = [UIFont systemFontOfSize:15];
        labelTitle.textColor = [UIColor darkTextColor];
        [self addSubview:labelTitle];
        [labelTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.centerY.equalTo(self);
        }];
        
        imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-15);
            make.centerY.equalTo(self);
            make.width.height.mas_equalTo(20);
        }];
    }
    return self;
}

- (void)setIsSeleted:(BOOL)isSeleted{
    _isSeleted = isSeleted;
    imageView.image = isSeleted ? [UIImage imageNamed:@"seletedindicator.png"] : nil;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    if (!title) {
        return;
    }
    labelTitle.text = title;
}

- (void)choseLockScreenTime{
    if (self.choseLockScreenTypeCallBack) {
        self.choseLockScreenTypeCallBack(self.lockScreenType,self);
    }
}


@end
