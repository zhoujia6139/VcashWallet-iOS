//
//  LeftMenuView.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/23.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "LeftMenuView.h"
#import "LeftMenuCell.h"
#import "LeftMenuModel.h"
#import "SettingViewController.h"

static NSString * const identifier = @"LeftMenuCell";

@interface LeftMenuView ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewContainer;

@property (nonatomic, strong) UIView *viewAlpha;

@end

@implementation LeftMenuView{
    NSMutableArray *_arrData;
    
    LeftMenuModel *priMenuModel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib{
    [super awakeFromNib];
    NSArray *arrImageName = @[@"wallet.png",@"setting.png",@"adressbook.png"];
    NSArray *arrHightImageName = @[@"wallet_hight.png",@"setting_hight.png",@"adressbook_hight.png"];
    NSArray *arrTitle = @[[LanguageService contentForKey:@"VcashWallet"],[LanguageService contentForKey:@"setting"],[LanguageService contentForKey:@"addressBook"]];
    _arrData = [NSMutableArray array];
    for (NSInteger i = 0; i < 3; i++) {
        LeftMenuModel *model = [LeftMenuModel new];
        model.imageName = arrImageName[i];
        model.imageHightName = arrHightImageName[i];
        model.title = arrTitle[i];
        [_arrData addObject:model];
    }
    
    [self.tableViewContainer registerNib:[UINib nibWithNibName:NSStringFromClass([LeftMenuCell class]) bundle:nil] forCellReuseIdentifier:identifier];
    
    self.tableViewContainer.separatorStyle = UITableViewCellSeparatorStyleNone;
    _viewAlpha = [[UIView alloc] init];
    _viewAlpha.backgroundColor = [UIColor blackColor];
    _viewAlpha.alpha = 0.3;
    _viewAlpha.hidden = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenAnimation)];
    [_viewAlpha addGestureRecognizer:tap];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (indexPath.row < _arrData.count) {
        LeftMenuModel *model = _arrData[indexPath.row];
        cell.model = model;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LeftMenuModel *model = _arrData[indexPath.row];
    priMenuModel.selected = NO;
    model.selected = !model.selected;
    priMenuModel = model;
    [tableView reloadData];
    if ([model.title isEqualToString:[LanguageService contentForKey:@"VcashWallet"]]) {
        [self hiddenAnimation];
        return;
    }
    if ([model.title isEqualToString:[LanguageService contentForKey:@"setting"]]) {
        SettingViewController *setVc = [[SettingViewController alloc] init];
        [[[[AppHelper shareInstance] visibleViewController] navigationController] pushViewController:setVc animated:YES];
        [self hiddenAnimation];
        return;
    }
}


- (void)addAlphaViewPanGesture:(UIPanGestureRecognizer *)pan{
    [self.viewAlpha addGestureRecognizer:pan];
}

- (void)addInView{
    UIWindow *wd= [[[UIApplication sharedApplication] delegate] window];
    [wd addSubview:self.viewAlpha];
    self.viewAlpha.frame = CGRectMake(0, 0, wd.size.width, wd.size.height);
    [wd addSubview:self];
    self.frame = CGRectMake(-wd.size.width * 3/4.0, 0, wd.size.width *3 / 4.0 , wd.size.height);
}

- (void)showAnimation{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect fra = self.frame;
        fra.origin.x = 0;
        self.frame = fra;
        self.viewAlpha.alpha = 0.3;
    } completion:^(BOOL finished) {
        self.viewAlpha.hidden = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(isHaveHidden:)]) {
            [self.delegate isHaveHidden:NO];
        }
    }];
}

- (void)hiddenAnimation{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect fra = self.frame;
        fra.origin.x = - fra.size.width;
        self.frame = fra;
        self.viewAlpha.alpha = 0;
    } completion:^(BOOL finished) {
        self.viewAlpha.hidden = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(isHaveHidden:)]) {
            [self.delegate isHaveHidden:YES];
        }
    }];
}

@end
