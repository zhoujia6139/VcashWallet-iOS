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

@property (nonatomic, strong) UIView *parentView;

@property (nonatomic, strong) UIView *releativeView;

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
        self.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowOpacity = 0.8;
        self.layer.shadowRadius = 4.0f;
        _arrData = arrData;
        _alphaView= [[UIView alloc]init];
        _alphaView.backgroundColor = [UIColor clearColor];
        _tableViewContainer = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableViewContainer.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
        _tableViewContainer.dataSource = self;
        _tableViewContainer.delegate = self;
        _tableViewContainer.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.tableViewContainer];
        [self.tableViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeViewFromSuperview)];
        [self.alphaView addGestureRecognizer:tap];
    }
    return self;
}

- (void)updateDataWith:(NSArray *)arrData{
    _arrData = arrData;
    if (_arrData.count == 0) {
        [self removeViewFromSuperview];
        return;
    }
    [self setWordViewFrame];
//    UIWindow *wd = [UIApplication sharedApplication].keyWindow;
//    CGFloat keyBoardHeight = [[YYTextKeyboardManager defaultManager] keyboardFrame].size.height;
//    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(wd).offset(10);
//        make.width.mas_equalTo(150);
//        make.height.mas_equalTo([self getHeight]);
//        make.bottom.equalTo(wd).offset(-keyBoardHeight);
//    }];
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
    cell.backgroundColor =  [UIColor colorWithHexString:@"#F5F5F5"];
    NSString *str = self.arrData[indexPath.row];
    NSString *prefixStr;
    if (self.releativeView) {
        for (UIView *iv in self.releativeView.subviews) {
            if ([iv isKindOfClass:[UITextField class]]) {
                UITextField *textField = (UITextField *)iv;
                prefixStr = textField.text;
                break;
            }
        }
        str = [str stringByReplacingOccurrencesOfString:[prefixStr lowercaseString] withString:@""];
        NSMutableAttributedString *mutableAttributedStr = [[NSMutableAttributedString alloc] initWithString:[prefixStr lowercaseString] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18]}];
        NSAttributedString *attributedStr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
        [mutableAttributedStr appendAttributedString:attributedStr];
        
        cell.textLabel.attributedText = mutableAttributedStr;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
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
    float count = self.arrData.count;
    if (count > 4) {
        count = 4.5;
    }
    CGFloat height = 40 * count;
    return height;
}

- (void)showInView:(UIView *)parentView releativeView:(UIView *)releativeView{
    if (self.superview) {
        return;
    }
    _parentView = parentView;
    _releativeView = releativeView;
    [self.parentView addSubview:self.alphaView];
    [self.alphaView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.parentView);
    }];
    
    [self.parentView addSubview:self];
    [self setWordViewFrame];
   
}

- (void)setWordViewFrame{
    CGFloat keyBoardHeight = [[YYTextKeyboardManager defaultManager] keyboardFrame].size.height;
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.releativeView.mas_bottom);
        make.centerX.equalTo(self.releativeView);
        make.width.mas_equalTo(self.releativeView);
        make.height.mas_equalTo([self getHeight]);
    }];
    [self.parentView layoutIfNeeded];
    if (ScreenHeight - self.origin.y - [self getHeight]  - kTopHeight < keyBoardHeight) {
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.releativeView.mas_top);
            make.centerX.equalTo(self.releativeView);
            make.width.mas_equalTo(self.releativeView);
            make.height.mas_equalTo([self getHeight]);
        }];
        [self.parentView layoutIfNeeded];
        if (self.origin.y < kTopHeight) {
            [[self.releativeView superview] layoutIfNeeded];
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.releativeView.mas_top);
                make.centerX.equalTo(self.releativeView);
                make.width.mas_equalTo(self.releativeView);
                if ([self.releativeView superview].origin.y + self.releativeView.origin.y > [self height]) {
                     make.height.mas_equalTo([self height]);
                }else{
                    make.height.mas_equalTo([self.releativeView superview].origin.y + self.releativeView.origin.y);
                }
               
            }];
        }
    }
    
}
@end
