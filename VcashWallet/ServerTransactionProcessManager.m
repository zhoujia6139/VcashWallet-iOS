//
//  ServerTransactionBlackManager.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/31.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "ServerTransactionProcessManager.h"

#define storagePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"serverTransactionBlack"]

@interface ServerTransactionProcessManager ()

@property (nonatomic, strong) NSMutableDictionary *dicData;

@end

@implementation ServerTransactionProcessManager

+ (id)shareInstance{
    static ServerTransactionProcessManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ServerTransactionProcessManager alloc] init];
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


- (void)writeProcessServerTransaction:(ServerTransaction *)serverTx{
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

- (BOOL)isProcessWithServerTransaction:(ServerTransaction *)serverTx{
    BOOL isBlack = [self.dicData objectForKey:serverTx.tx_id] ? YES : NO;
    return isBlack;
}

- (NSDictionary *)readServerTransactions{
    if (self.dicData.allKeys.count > 0) {
        return self.dicData;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithFile:storagePath];
}

@end
