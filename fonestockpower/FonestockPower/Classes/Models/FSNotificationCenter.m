//
//  FSNotificationCenter.m
//  WirtsLeg
//
//  Created by Connor on 14/2/12.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import "FSNotificationCenter.h"
#import "Reachability.h"
#import "FSLoginService.h"

// 登入成功
NSString *const kFSLoginSuccessNotification = @"loginServiceStatus";
// 登入失敗
NSString *const kFSLoginFailNotification = @"kFSLoginFailNotification";
// 登入成功
NSString *const kFSLoginInitNotification = @"kFSLoginInitNotification";

// 股票商品代碼回傳通知
NSString *const kFSSecurityRegisterCallBackNotification = @"kFSSecurityRegisterCallBackNotification";

//Tick 回補
NSString *const kFSTickDataCallBackNotification = @"kFSTickDataCallBackNotification";

@interface FSNotificationCenter()
@property (strong, nonatomic) Reachability *reach;
@end

@implementation FSNotificationCenter

+ (FSNotificationCenter *)sharedInstance {
    static FSNotificationCenter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FSNotificationCenter alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        [self registerLoginNotification];
        [self registerReachabilityNotification];
//        [self registerSecurityRegisterNotification];
    }
    return self;
}

#pragma mark -
#pragma mark - 連線狀態變更 通知
- (void)registerReachabilityNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    self.reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    [self.reach startNotifier];
}

- (void)reachabilityChanged:(NSNotification *)note {
    if ([self.reach currentReachabilityStatus] == NotReachable) {
//        [[[UIAlertView alloc] initWithTitle:@"Connection Failed!" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
    } else {
        // 重新登入
        FSLoginService *loginService = [[FSDataModelProc sharedInstance] loginService];
        if (loginService.loginCounter > 1) {
            [loginService loginAuth];
        }
    }
}

#pragma mark -
#pragma mark - 登入行為狀態 通知
- (void)registerLoginNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginSuccessNotification:)
                                                 name:@"loginServiceStatus"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginFailNotification:)
                                                 name:@"loginServiceStatus"
                                               object:nil];
}

- (void)loginSuccessNotification:(NSNotification *)note {
//    NSString *notificationString = NSLocalizedStringFromTable(@"Login Success", @"ConnectionWarning", nil);
        FSLoginResultType authResultType = [[note object] intValue];
    if (authResultType == FSLoginResultTypeServiceServerLoginSuccess) {
        
    }
}

- (void)loginFailNotification:(NSNotification *)note {
//    NSString *notificationString = NSLocalizedStringFromTable(@"Login Fail", @"ConnectionWarning", nil);

}


-(void)dealloc {
    
}

@end
