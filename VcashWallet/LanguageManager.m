//
//  LanguageManager.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/22.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "LanguageManager.h"

@interface LanguageManager ()

@property (nonatomic, strong) NSDictionary *dicText;

@end

@implementation LanguageManager

+ (id)shareInstance{
    static LanguageManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LanguageManager alloc] init];
    });
    return manager;
}

- (NSString *)contentForKey:(NSString *)key{
    if (!_dicText) {
        _dicText = [self readContentFromLanguageFile];
    }
    NSString *content = [_dicText objectForKey:key];
    return  content ? content : @"";
}

- (NSDictionary *)readContentFromLanguageFile{
   NSDictionary *dic = [self dataFromJsonFileName:@"en"];
   return dic;
}

- (NSDictionary *)dataFromJsonFileName:(NSString *)fileName{
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        return nil;
    }
    return dic;
}

@end
