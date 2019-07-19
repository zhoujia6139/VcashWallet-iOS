//
//  ContainWordView.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/7/19.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "ContainWordView.h"

static NSString * const identifier = @"UITableViewCell";

@interface ContainWordView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableViewContainer;

@property (nonatomic, strong) NSArray *arrData;

@property (nonatomic, strong) UIView *alphaView;

@end

@implementation ContainWordView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithArrData:(NSArray *)arrData{
    self = [super init];
    if (self) {
        _arrData = arrData;
        _alphaView= [[UIView alloc]init];
        _alphaView.backgroundColor = [UIColor clearColor];
        _tableViewContainer = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableViewContainer.dataSource = self;
        _tableViewContainer.delegate = self;
        [self addSubview:self.tableViewContainer];
        [self.tableViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromSuperview)];
        [self.alphaView addGestureRecognizer:tap];
    }
    return self;
}

- (void)updateDataWith:(NSArray *)arrData{
    _arrData = arrData;
    if (_arrData.count == 0) {
        [self removeFromSuperview];
        return;
    }
    UIWindow *wd = [UIApplication sharedApplication].keyWindow;
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wd).offset(10);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo([self getHeight]);
        make.bottom.equalTo(wd).offset(-380);
    }];
    [self.tableViewContainer reloadData];
}

- (void)removeViewFromSuperview{
    [self.alphaView removeFromSuperview];
    [self removeFromSuperview];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = self.arrData[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.seletedWordCallBack) {
        NSString *word = self.arrData[indexPath.row];
        self.seletedWordCallBack(word);
        [self removeViewFromSuperview];
    }
}

- (CGFloat)getHeight{
    CGFloat height = 44 * self.arrData.count;
    if (height > ScreenHeight - kTopHeight - 380) {
        height = ScreenHeight - kTopHeight - 380;
    }
    return height;
}

- (void)show{
    if (self.superview) {
        return;
    }
    UIWindow *wd = [UIApplication sharedApplication].keyWindow;
    [wd addSubview:self.alphaView];
    [self.alphaView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(wd);
    }];
    
    [wd addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wd).offset(10);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo([self getHeight]);
        make.bottom.equalTo(wd).offset(-380);
    }];
}
@end
