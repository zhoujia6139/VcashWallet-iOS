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

-(BOOL)saveOutputData:(NSArray*)array{
    if (array.count == 0){
        return YES;
    }
    
    NSString *className = NSStringFromClass(VcashOutput.class);
    NSString *tableName = className;
    BOOL ret = [self.database insertOrReplaceObjects:array
                                                into:tableName];
    if (!ret)
    {
        DDLogError(@"----------db error, saveOutputData fail");
        return NO;
    }
    return YES;
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
        
    }
    
    return _database;
}
@end
