//
//  RefreshStateHeader.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/6/4.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "RefreshStateHeader.h"

@implementation RefreshStateHeader

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)prepare{
    [super prepare];
    self.lastUpdatedTimeLabel.hidden = YES;
    [self setTitle:[LanguageService contentForKey:@"MJRefreshHeaderIdleText"] forState:MJRefreshStateIdle];
    [self setTitle:[LanguageService contentForKey:@"MJRefreshHeaderPullingText"] forState:MJRefreshStatePulling];
    [self setTitle:[LanguageService contentForKey:@"MJRefreshHeaderRefreshingText"] forState:MJRefreshStateRefreshing];
}

@end
