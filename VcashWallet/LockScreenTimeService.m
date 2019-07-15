//
//  LocckScreenTimeService.m
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/6/3.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "LockScreenTimeService.h"
#import "LeftMenuManager.h"
#import "LocalAuthenticationManager.h"
#import "TouchIdOrFaceIDViewController.h"

#define storageLockTypePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"lockTypePath"]

@interface LockScreenTimeService ()

@property (nonatomic, assign) LockScreenType lockScreenType;

@property (nonatomic, strong) NSDate *startDate;

@end

@implementation LockScreenTimeService

+ (id)shareInstance{
    static LockScreenTimeService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[LockScreenTimeService alloc] init];
    });
    return service;
}

- (void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.lockScreenType = [self readLockScreenType];
    }
    return self;
}


- (void)enterForeground{
    if (!self.startDate) {
        return;
    }
    NSDate *date = [NSDate date];
    NSInteger seconds = ([date timeIntervalSince1970] - [self.startDate timeIntervalSince1970]);
    switch (self.lockScreenType) {
        case LockScreenTypeNever:
            
            break;
        case LockScreenType30Seonds:{
            if (seconds > 30) {
                [self showPasswordVerifyVc];
            }else{
                [self showTouchIDOrFaceIDVc];
            }
        }
            break;
        case LockScreenType1Minute:{
            if (seconds > 60) {
                [self showPasswordVerifyVc];
            }else{
                [self showTouchIDOrFaceIDVc];
            }
        }
            break;
        case LockScreenType3Minutes:{
            if (seconds > 3 * 60) {
                [self showPasswordVerifyVc];
            }else{
                [self showTouchIDOrFaceIDVc];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)enterBackground{
    self.startDate = [NSDate date];
}

- (void)showTouchIDOrFaceIDVc{
    if ([[LocalAuthenticationManager shareInstance] getEnableAuthentication]) {
        [[[[AppHelper shareInstance] visibleViewController] navigationController] dismissViewControllerAnimated:NO completion:nil];
        TouchIdOrFaceIDViewController *verifyVc = [[TouchIdOrFaceIDViewController alloc] init];
        [[[[AppHelper shareInstance] visibleViewController] navigationController] presentViewController:verifyVc animated:YES completion:nil];
    }
}

- (void)showPasswordVerifyVc{
    if ([[UserCenter sharedInstance] checkUserHaveWallet]){
        [NavigationCenter showPasswordVerifyPage];
        [[LeftMenuManager shareInstance] removeGestures];
        [[[LeftMenuManager shareInstance] leftMenuView] refreshData];
    }
}


- (void)writeLockScreenType:(LockScreenType)type{
    _lockScreenType = type;
    NSURL *url = [NSURL URLWithString:storageLockTypePath];
    NSError *error = nil;
    BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if (!success) {
        DDLogError(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
    }
    BOOL storageSuc = [NSKeyedArchiver archiveRootObject:@(type) toFile:storageLockTypePath];
    if (!storageSuc) {
        DDLogError(@"storage serverTx failed");
    }
}

- (LockScreenType)readLockScreenType{
   return  [[NSKeyedUnarchiver unarchiveObjectWithFile:storageLockTypePath] integerValue];
}



@end
