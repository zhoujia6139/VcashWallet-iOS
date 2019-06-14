//
//  VcashDataManager.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/23.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "VcashDataManager.h"
#import <WCDB/WCDB.h>
#import "VcashOutput+WCTTableCoding.h"
#import "VcashWalletInfo+WCTTableCoding.h"
#import "VcashTxLog+WCTTableCoding.h"
#import "VcashContext+WCTTableCoding.h"

@interface VcashDataManager()

@property (nonatomic, strong)NSString* baseDic;

@property (nonatomic, strong)WCTDatabase* database;

@end

@implementation VcashDataManager
{
    NSString* basePath;
}

+ (instancetype)shareInstance{
    static id config = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        config = [[self alloc] init];
    });
    return config;
}

-(void)closeDatabase
{
    [self.database close:^{
    }];
    self.database = nil;
}

-(void)clearAllData{
    NSString *className0 = NSStringFromClass(VcashOutput.class);
    [self.database dropTableOfName:className0];
    
    NSString *className1 = NSStringFromClass(VcashWalletInfo.class);
    [self.database dropTableOfName:className1];
    
    NSString *className2 = NSStringFromClass(VcashTxLog.class);
    [self.database dropTableOfName:className2];
    
    NSString *className3 = NSStringFromClass(VcashContext.class);
    [self.database dropTableOfName:className3];
    
    [self closeDatabase];
}

-(BOOL)saveWalletInfo:(VcashWalletInfo*)info{
    NSString *className = NSStringFromClass(VcashWalletInfo.class);
    NSString *tableName = className;
    info.infoid = 0;
    BOOL ret = [self.database insertOrReplaceObject:info into:tableName];
    if (!ret)
    {
        DDLogError(@"----------db error, saveWalletInfo fail");
        return NO;
    }
    return YES;
}

-(VcashWalletInfo*)loadWalletInfo{
    NSString *className = NSStringFromClass(VcashWalletInfo.class);
    NSString *tableName = className;
    VcashWalletInfo *object = [self.database getOneObjectOfClass:VcashWalletInfo.class
                                                         fromTable:tableName];
    
    return object;
}

-(BOOL)saveOutputData:(NSArray*)array{
    if (array.count == 0){
        return YES;
    }
    
    NSString *className = NSStringFromClass(VcashOutput.class);
    NSString *tableName = className;
    [self.database deleteAllObjectsFromTable:tableName];
    BOOL ret = [self.database insertOrReplaceObjects:array
                                                into:tableName];
    if (!ret)
    {
        DDLogError(@"----------db error, saveOutputData fail");
        return NO;
    }
    return YES;
}

-(NSArray*)getActiveOutputData{
    NSString *className = NSStringFromClass(VcashOutput.class);
    NSString *tableName = className;
    NSArray<VcashOutput *> *objects = [self.database getObjectsOfClass:VcashOutput.class fromTable:tableName where:(VcashOutput.status != Spent)];
    NSMutableArray* arr = [NSMutableArray new];
    for (VcashOutput * item in objects){
        if ([self getTxByTxId:item.tx_log_id]){
            [arr addObject:item];
        }
    }
    return arr;
}

-(BOOL)saveTxDataArr:(NSArray*)arr{
    if (arr.count == 0){
        return YES;
    }
    
    NSString *className = NSStringFromClass(VcashTxLog.class);
    NSString *tableName = className;
    [self.database deleteAllObjectsFromTable:tableName];
    BOOL ret = [self.database insertObjects:arr into:tableName];
    if (!ret)
    {
        DDLogError(@"----------db error, saveTxData fail");
        return NO;
    }
    return YES;
}

-(BOOL)saveTx:(VcashTxLog*)txLog{
    if (!txLog){
        return YES;
    }
    
    NSString *className = NSStringFromClass(VcashTxLog.class);
    NSString *tableName = className;
    BOOL ret = [self.database insertOrReplaceObject:txLog into:tableName];
    if (!ret)
    {
        DDLogError(@"----------db error, saveAppendTx fail");
        return NO;
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:kTxLogDataChanged object:nil];
    return YES;
}

- (BOOL)deleteTxBySlateId:(NSString *)slate_id{
    NSString *className = NSStringFromClass(VcashTxLog.class);
    NSString *tableName = className;
    BOOL ret = [self.database deleteObjectsFromTable:tableName where:VcashTxLog.tx_slate_id == slate_id];
    if (!ret)
    {
        DDLogError(@"----------db error, deleteTx fail");
        return NO;
    }
    return YES;
}

-(VcashTxLog*)getTxBySlateId:(NSString*)slate_id{
    NSString *className = NSStringFromClass(VcashTxLog.class);
    NSString *tableName = className;
    NSArray<VcashTxLog *> *objects = [self.database getObjectsOfClass:VcashTxLog.class fromTable:tableName where:VcashTxLog.tx_slate_id == slate_id];

    return objects.firstObject;
}

-(VcashTxLog*)getTxByTxId:(uint32_t)tx_id{
    NSString *className = NSStringFromClass(VcashTxLog.class);
    NSString *tableName = className;
    NSArray<VcashTxLog *> *objects = [self.database getObjectsOfClass:VcashTxLog.class fromTable:tableName where:VcashTxLog.tx_id == tx_id];
    
    return objects.firstObject;
}

-(NSArray*)getTxData{
    NSString *className = NSStringFromClass(VcashTxLog.class);
    NSString *tableName = className;
    NSArray<VcashTxLog *> *objects = [self.database getObjectsOfClass:VcashTxLog.class fromTable:tableName orderBy:VcashTxLog.tx_id.order(WCTOrderedAscending)];
    return objects;
}

-(BOOL)saveContext:(VcashContext*)context{
    if (!context){
        return YES;
    }
    
    NSString *className = NSStringFromClass(VcashContext.class);
    NSString *tableName = className;
    BOOL ret = [self.database insertObject:context into:tableName];
    if (!ret)
    {
        DDLogError(@"----------db error, saveContext fail");
        return NO;
    }
    return YES;
}

-(VcashContext*)getContextBySlateId:(NSString*)slateid{
    NSString *className = NSStringFromClass(VcashContext.class);
    NSString *tableName = className;
    VcashContext *object = [self.database getOneObjectOfClass:VcashContext.class
                                                       fromTable:tableName where:VcashContext.slate_id == slateid];
    
    return object;
}

-(BOOL)beginDatabaseTransaction{
    return [self.database beginTransaction];
}

-(BOOL)commitDatabaseTransaction{
    return [self.database commitTransaction];
}

-(BOOL)rollbackDataTransaction{
    return [self.database rollbackTransaction];
}

#pragma mark private method
- (NSString *)baseDic{
    if (!_baseDic)
    {
        NSString* directory = @"walletdb";
        _baseDic = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:directory];
    }
    
    return _baseDic;
}

-(WCTDatabase*) database
{
    if (!_database)
    {
        NSString *path = [self.baseDic stringByAppendingPathComponent:@"database"];
        _database = [[WCTDatabase alloc] initWithPath:path];
        //_database check
        
        NSString *className0 = NSStringFromClass(VcashOutput.class);
        NSString *tableName0 = className0;
        BOOL isExist = [_database isTableExists:tableName0];
        if (!isExist)
        {
            BOOL ret = [_database createTableAndIndexesOfName:tableName0 withClass:VcashOutput.class];
            assert(ret);
        }
        
        NSString *className1 = NSStringFromClass(VcashWalletInfo.class);
        NSString *tableName1 = className1;
        isExist = [_database isTableExists:tableName1];
        if (!isExist)
        {
            BOOL ret = [_database createTableAndIndexesOfName:tableName1 withClass:VcashWalletInfo.class];
            assert(ret);
        }
        
        NSString *className2 = NSStringFromClass(VcashTxLog.class);
        NSString *tableName2 = className2;
        isExist = [_database isTableExists:tableName2];
        if (!isExist)
        {
            BOOL ret = [_database createTableAndIndexesOfName:tableName2 withClass:VcashTxLog.class];
            assert(ret);
        }
        
        NSString *className3 = NSStringFromClass(VcashContext.class);
        NSString *tableName3 = className3;
        isExist = [_database isTableExists:tableName3];
        if (!isExist)
        {
            BOOL ret = [_database createTableAndIndexesOfName:tableName3 withClass:VcashContext.class];
            assert(ret);
        }
    }
    
    return _database;
}
@end
