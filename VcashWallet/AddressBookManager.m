//
//  AddressBookManager.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/7/12.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "AddressBookManager.h"

#define storagePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"addressBook"]

@interface AddressBookManager ()

@property (nonatomic, strong) NSMutableDictionary *dicData;

@end

@implementation AddressBookManager

+ (id)shareInstance{
    static AddressBookManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AddressBookManager alloc] init];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        NSDictionary *dic = [self readAddressBook];
        if (!dic) {
            _dicData = [NSMutableDictionary dictionary];
        }else{
            _dicData = [NSMutableDictionary dictionaryWithDictionary:dic];
        }
    }
    return self;
}

- (BOOL)isExistByAddressBookModel:(AddressBookModel *)model{
   return  [self.dicData objectForKey:model.address];
}

- (BOOL)deleteAddressBookModel:(AddressBookModel *)model{
    AddressBookModel *addressModel = [self.dicData objectForKey:model.address];
    if (addressModel) {
        [self.dicData removeObjectForKey:addressModel.address];
        NSURL *url = [NSURL URLWithString:storagePath];
        NSError *error = nil;
        BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if (!success) {
            DDLogError(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
        }
        BOOL storageSuc = [NSKeyedArchiver archiveRootObject:self.dicData toFile:storagePath];
        if (!storageSuc) {
            DDLogError(@"delete addressBookModel failed");
        }
        return storageSuc;
    }
    return NO;
}

- (BOOL)writeAddressBookModel:(AddressBookModel *)model{
    AddressBookModel *addressModel = [self.dicData objectForKey:model.address];
    [self.dicData setObject:model forKey:model.address];
    NSURL *url = [NSURL URLWithString:storagePath];
    NSError *error = nil;
    BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if (!success) {
        DDLogError(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
    }
    BOOL storageSuc = [NSKeyedArchiver archiveRootObject:self.dicData toFile:storagePath];
    if (!storageSuc) {
        DDLogError(@"storage addressBookModel failed");
    }
    return storageSuc;
}

- (NSArray<AddressBookModel *> *)getAddressBook{
    return self.dicData.allValues;
}

- (NSDictionary *)readAddressBook{
    if (self.dicData.allKeys.count > 0) {
        return self.dicData;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithFile:storagePath];
}



@end
