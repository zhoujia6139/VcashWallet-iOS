//
//  LocalAuthenticationManager.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/7/15.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "LocalAuthenticationManager.h"


#define storageAuthenticationPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"localAuthentication"]

@interface LocalAuthenticationManager ()

@property (nonatomic, strong) LAContext *context;

@end

@implementation LocalAuthenticationManager


+ (id)shareInstance{
    static LocalAuthenticationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LocalAuthenticationManager alloc] init];
    });
    return manager;
}

- (void)supportTouchIDOrFaceIDWithSupport:(void(^)(BOOL support))support Error:(void(^)(NSError *error))error{
    if (@available(iOS 9.0,*)) {
        NSError *authError = nil;
        _context = [[LAContext alloc] init];
        _context.localizedFallbackTitle = @"";
        BOOL isCanEvaluatePolicy = [self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError];
        if (error) {
            error(authError);
        }else{
            support(isCanEvaluatePolicy);
        }
    }else{
        return support(NO);
    }
}


- (void)verifyIdentidyWithComplete:(void(^)(BOOL success, NSError * __nullable error))complete{
    _context = [[LAContext alloc] init];
    _context.localizedFallbackTitle = @"";
    [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:[LanguageService contentForKey:@"touchIDReason"] reply:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(success,error);
            }
            if (@available(iOS 11.0, *)) {
                if (error.code == LAErrorTouchIDLockout || error.code == LAErrorBiometryLockout) {
                    if (iPhoneX) {
                        [MBHudHelper showTextTips:[LanguageService contentForKey:@"faceIDLocked"] onView:nil withDuration:2];
                    }else{
                        [MBHudHelper showTextTips:[LanguageService contentForKey:@"touchIDLocked"] onView:nil withDuration:2];
                    }
                }
            } else {
                // Fallback on earlier versions
                if (error.code == LAErrorTouchIDLockout) {
                    [MBHudHelper showTextTips:[LanguageService contentForKey:@"touchIDLocked"] onView:nil withDuration:2];
                }
            }
        });
    }];
}

- (void)saveEnableAuthentication:(BOOL)enable{
    NSURL *url = [NSURL URLWithString:storageAuthenticationPath];
    NSError *error = nil;
    BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if (!success) {
        DDLogError(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
    }
    BOOL storageSuc = [NSKeyedArchiver archiveRootObject:@(enable) toFile:storageAuthenticationPath];
    if (!storageSuc) {
        DDLogError(@"storage authentication failed");
    }
}

- (BOOL)getEnableAuthentication{
    return [[NSKeyedUnarchiver unarchiveObjectWithFile:storageAuthenticationPath] boolValue];
}

@end
