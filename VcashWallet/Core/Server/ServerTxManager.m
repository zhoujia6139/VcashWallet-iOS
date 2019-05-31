//
//  ServerTxManager.m
//  VcashWallet
//
//  Created by jia zhou on 2019/5/7.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "ServerTxManager.h"
#import "ServerApi.h"
#import "VcashSlate.h"
#import "ServerTxPopView.h"
#import "MessageNotificationView.h"
#import "ServerTransactionBlackManager.h"

#define TimerInterval 5

@interface ServerTxManager()

@property(strong, nonatomic)NSMutableArray* txArr;

@property(strong, nonatomic)MessageNotificationView* msgNotificationView;

@end

@implementation ServerTxManager
{
    NSTimer* _timer;
}

+ (instancetype)shareInstance{
    static id config = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        config = [[self alloc] init];
    });
    return config;
}

-(void)startWork{
    if (!_timer){
        __weak typeof (self) weak_self = self;
        _timer = [NSTimer scheduledTimerWithTimeInterval:TimerInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
            __strong typeof (weak_self) strong_self = weak_self;
            [strong_self fetchTxStatus:NO];
        }];
    }
    
    [_timer setFireDate:[NSDate date]];
}

-(void)stopWork{
    [_timer invalidate];
    _timer = nil;
}

-(void)fetchTxStatus:(BOOL)force{
    static NSTimeInterval lastFetch = 0;
    if (force || [[NSDate date] timeIntervalSince1970] - lastFetch  >= (TimerInterval-1)){
        [[ServerApi shareInstance] checkStatusForUser:[VcashWallet shareInstance].userId WithComplete:^(BOOL yesOrNo, NSArray<ServerTransaction*>* txs) {
            DDLogInfo(@"check status ret %@ tx ", @(txs.count));
            if (yesOrNo){
                lastFetch = [[NSDate date] timeIntervalSince1970];
                for (ServerTransaction* item in txs){
                    item.slateObj = [VcashSlate modelWithJSON:item.slate];
                    if (item && item.slateObj){
                        VcashTxLog *txLog = [[VcashDataManager shareInstance] getTxBySlateId:item.slateObj.uuid];
                        
                        //check as receiver
                        if ([item.receiver_id isEqualToString:[VcashWallet shareInstance].userId]){
                            if (item.status == TxFinalized ||
                                item.status == TxCanceled){
                                if (txLog && txLog.confirm_state == DefaultState){
                                    switch (item.status) {
                                        case TxFinalized:
                                            txLog.confirm_state = LoalConfirmed;
                                            break;
                                        case TxCanceled:
                                            txLog.tx_type = TxReceivedCancelled;
                                            break;
                                            
                                        default:
                                            break;
                                    }
                                    txLog.status = item.status;
                                    [[VcashDataManager shareInstance] saveTx:txLog];
                                }
                                [[ServerApi shareInstance] closeTransaction:item.tx_id];
                                continue;
                            }
                        }
                        //check as sender
                        else if ([item.sender_id isEqualToString:[VcashWallet shareInstance].userId]){
                            //check is cancelled
                            if (txLog.status == TxCanceled){
                                [[ServerApi shareInstance] cancelTransaction:txLog.tx_slate_id WithComplete:^(BOOL yesOrNo, id _Nullable data) {
                                }];
                                continue;
                            }
                            
                            //check is finalized
                            if (txLog.status == TxFinalized){
                                [[ServerApi shareInstance] filanizeTransaction:txLog.tx_slate_id WithComplete:^(BOOL yesOrNo, id _Nullable data) {
                                }];
                                continue;
                            }
                            
                            if (item.status == TxReceiverd){
                                txLog.status = item.status;
                                [[VcashDataManager shareInstance] saveTx:txLog];
                            }
                        }
                        
                        //if goes here item.status would be TxDefaultStatus or TxReceiverd
                        BOOL isRepeat = NO;
                        for (ServerTransaction* tx in self.txArr){
                            if ([tx.tx_id isEqualToString:item.tx_id]){
                                isRepeat = YES;
                                break;
                            }
                        }
                        if (!isRepeat){
                            [self.txArr addObject:item];
                        }
                    }
                    else if (item){
                        DDLogError(@"receive a illegal tx:%@", [item modelToJSONString]);
                    }
                }
                [self handleServerTx];
            }
            else{
                lastFetch = 0;
            }
        }];
    }
}

-(void)handleServerTx{
    ServerTransaction* item = [self.txArr firstObject];
    BOOL isBlack =  [[ServerTransactionBlackManager shareInstance] isBlackWithServerTransaction:item];
    if (isBlack) {
        return;
    }
    if (item && !self.msgNotificationView.superview){
        if ([item.sender_id isEqualToString:[VcashWallet shareInstance].userId]){
            item.isSend = YES;
        }
        else if ([item.receiver_id isEqualToString:[VcashWallet shareInstance].userId]){
            item.isSend = NO;
        }
        else{
            DDLogError(@"-----------get a servertx not belong to me!!");
            return;
        }
        
        self.msgNotificationView.serverTx = item;
        [self.msgNotificationView show];
        
        [self.txArr removeObject:item];
    }
}

-(NSMutableArray*)txArr{
    if (!_txArr){
        _txArr = [NSMutableArray new];
    }
    
    return _txArr;
}

- (MessageNotificationView *)msgNotificationView{
    if (!_msgNotificationView){
        _msgNotificationView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([MessageNotificationView class]) owner:self options:nil][0];
    }
    
    return _msgNotificationView;
}


@end
