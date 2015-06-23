//
//  FSFonestock.h
//  FonestockPower
//
//  Created by Connor on 14/3/23.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSUtility.h"

#import "FSDateFormat.h"
#import "FSBTimeFormat.h"
#import "FSBValueFormat.h"
#import "Tips_location_up.pb.h"

#if defined(PatternPowerUS)

#define LPCB 1

#endif

#if defined(PatternPowerTW)

#define LPCB 1

#endif

#define LPCB 1

@class Authority;
@class FSLauncherPageViewController;

@interface FSFonestock : NSObject

typedef NS_ENUM(NSUInteger, FSAPPVersion) {
    FSAPPVersionPatternPower,
    FSAPPVersionStrategyPower
};

typedef NS_ENUM(NSUInteger, FSMarketVersion) {
    FSMarketVersionUS = 0,
    FSMarketVersionCN,
    FSMarketVersionTW
};

// 廣告種類
typedef NS_ENUM(NSUInteger, FSAdvertiseBannerType) {
    FSAdvertiseBannerTypeNone = 0,          // 0: 沒有廣告區
    FSAdvertiseBannerTypeAdmob,             // 1: 有廣告區, 且送廣告
    FSAdvertiseBannerTypeFonestockMarquee   // 2: 有廣告區, 但是顯示的是跑馬燈
};

// 權限種類
typedef NS_ENUM(NSUInteger, FSPermissionType) {
    FSPermissionTypePatternSearchInSession = 0,     // 0: 圖示選股 盤中搜尋
    FSPermissionTypeEODNewTarget,                   // 1: EOD New Target
    FSPermissionTypeEODCheckALL,                    // 2: EDO Check All
    FSPermissionTypeStrategyAlert,                  // 3: 策略警示
    FSPermissionTypePortRelateKLine,                // 4: portfolio 進入K線權限
    FSPermissionTypeJournalRelateKline,             // 5: journal 進入K線權限
    FSPermissionTypePressSupport                    // 6: 進入支壓圖權限
};

@property (weak, nonatomic) UIViewController *currentViewController;
@property (readonly, nonatomic) NSString *authenticationServerURL;
@property (readonly, nonatomic) NSString *authType;
@property (readonly, nonatomic) NSString *account;
@property (readonly, nonatomic) NSString *password;
@property (readonly, nonatomic) NSString *appId;
@property (readonly, nonatomic) NSString *lang;
@property (readonly, nonatomic) FSMarketVersion marketVersion;
@property (readonly, nonatomic) NSString *mainPageAdvertiseURL;
@property (readonly, nonatomic) NSString *mainDBName;
@property (readonly, nonatomic) NSString *signupPageURL;
@property (readonly, nonatomic) NSString *paymentPageURL;
@property (readonly, nonatomic) NSString *purchaseVerifyURL;
@property (readonly, nonatomic) NSString *updatePushNotificationTokenURL;
@property (readonly, nonatomic) NSString *FBShareNotificationURL;
@property (readonly, nonatomic) NSString *appStoreURL;
@property (readonly, nonatomic) NSString *forgotPasswordURL;
@property (readonly, nonatomic) NSString *openProjectURL;
@property (readonly, nonatomic) NSString *checkSubscriptionURL;
@property (readonly, nonatomic) NSInteger TipsLocationUpdataType;


@property (strong, nonatomic) NSString *queryServerURL;
@property (unsafe_unretained, nonatomic) NSInteger portfolioQuota;

@property (strong, nonatomic) Authority *authorityData;

@property (nonatomic, strong) FSLauncherPageViewController *launcherTarget;
-(void)setTarget:(FSLauncherPageViewController *)aTarget;




@property BOOL twoStockMode;




+ (instancetype)sharedInstance;

+ (NSString *)appName;          /* project name */
+ (NSString *)appDisplayName;   /* display name (localizedString) */
+ (NSString *)appVersion;       /* app version, like 1.0 */
+ (NSString *)appBuildNo;       /* app build No, like 1, 2, 3.... */
+ (NSString *)appBundleId;      /* app bundle unique ID, like com.fonestock.xxLeads */
+ (NSString *)appFullVersion;
+ (NSString *)appClientInfo;

+ (NSString *)uuid;
+ (NSString *)manufacturingFactory;
+ (NSString *)machineModelNumber;
+ (NSString *)operatingSystemVersion;

+ (NSString *)appBundleFilePath:(NSString *)filename;
- (NSString *)appMainDatabaseFilePath;
- (NSString *)appMainDatabaseBundleFilePath;

- (BOOL)checkPermission:(FSPermissionType)type showAlertViewToShopping:(BOOL)show;
- (BOOL)checkNeedShowAdvertise;

@end

@interface Authority : NSObject
@property (unsafe_unretained, nonatomic) BOOL insession;                // 圖示選股 盤中搜尋
@property (unsafe_unretained, nonatomic) BOOL eod_new_target;           // EOD New Target
@property (unsafe_unretained, nonatomic) BOOL eod_check_all;            // EDO Check All
@property (unsafe_unretained, nonatomic) BOOL strategy_alert;           // 策略警示
@property (unsafe_unretained, nonatomic) BOOL port_relate_kline;        // portfolio 進入K線權限
@property (unsafe_unretained, nonatomic) BOOL journal_relate_kline;     // journal 進入K線權限
@property (unsafe_unretained, nonatomic) BOOL press_support;            // 進入支壓圖權限
@property (unsafe_unretained, nonatomic) FSAdvertiseBannerType adv_on;  // 廣告狀態
@property (unsafe_unretained, nonatomic) NSInteger portfolio_quota;     // 自選股支數
@property (unsafe_unretained, nonatomic) BOOL kchart;                   // 有沒有K線

@end
