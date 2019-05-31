//
//  ServerTransactionBlackManager.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/31.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "ServerTransactionBlackManager.h"

#define storagePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"serverTransactionBlack"]

@interface ServerTransactionBlackManager ()

@property (nonatomic, strong) NSMutableDictionary *dicData;

@end

@implementation ServerTransactionBlackManager

+ (id)shareInstance{
    static ServerTransactionBlackManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ServerTransactionBlackManager alloc] init];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        NSDictionary *dic = [self readServerTransactions];
        if (!dic) {
            _dicData = [NSMutableDictionary dictionary];
        }else{
            _dicData = [NSMutableDictionary dictionaryWithDictionary:dic];
        }
    }
    return self;
}


- (void)writeBlackServerTransaction:(ServerTransaction *)serverTx{
    ServerTransaction *transaction = [self.dicData objectForKey:serverTx.tx_id];
    if (!transaction) {
       [self.dicData setObject:serverTx forKey:serverTx.tx_id];
        NSURL *url = [NSURL URLWithString:storagePath];
        NSError *error = nil;
        BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if (!success) {
            DDLogError(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
        }
       BOOL storageSuc = [NSKeyedArchiver archiveRootObject:self.dicData toFile:storagePath];
        if (!storageSuc) {
            DDLogError(@"storage serverTx failed");
        }
    }
}

- (BOOL)isBlackWithServerTransaction:(ServerTransaction *)serverTx{
    BOOL isBlack = [self.dicData objectForKey:serverTx.tx_id] ? YES : NO;
    return isBlack;
}

- (NSDictionary *)readServerTransactions{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:storagePath];
}

@end
