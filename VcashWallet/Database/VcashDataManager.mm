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

-(BOOL)saveWalletInfo:(VcashWalletInfo*)info{
    NSString *className = NSStringFromClass(VcashWalletInfo.class);
    NSString *tableName = className;
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
    return objects;
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
    }
    
    return _database;
}
@end
