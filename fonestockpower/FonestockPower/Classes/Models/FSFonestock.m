//
//  FSFonestock.m
//  FonestockPower
//
//  Created by Connor on 14/3/23.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSFonestock.h"
#import "KeychainItemWrapper.h"
#import "FSLauncherPageViewController.h"

@interface FSFonestock()<UIAlertViewDelegate> {
    UIAlertView *alertView;
}

@end

@implementation FSFonestock

static FSFonestock *sharedInstance = nil;

+ (id)sharedInstance {
    @synchronized([FSFonestock class]) {
        //判斷FSFonestock是否完成記憶體配置
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
            [sharedInstance fonestockInit];
        }
        return sharedInstance;
    }
    return nil;
}

+ (id)alloc {
    @synchronized([FSFonestock class]) {
        // 避免 [FSFonestock alloc] 方法被濫用
        NSAssert(sharedInstance == nil, @"FSFonestock 已經做過記憶體配置");
        sharedInstance = [super alloc];
        return sharedInstance;
    }
    return nil;
}

- (id)init {
    if (self = [super init]) {
        _launcherTarget = [[FSLauncherPageViewController alloc] init];
    }
    return self;
}

- (void)fonestockInit {
    NSString *sysPropertyFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"SystemProperty.plist"];
    
    NSDictionary *sysParameters = [[NSDictionary alloc] initWithContentsOfFile:sysPropertyFilePath];
    
    _TipsLocationUpdataType = [[sysParameters objectForKey:@"TipsLocationUpdataType"]integerValue];
    _authenticationServerURL = [sysParameters objectForKey:@"AuthenticationServerURL"];
    _appId = [sysParameters objectForKey:@"AppId"];
    _lang = [_appId substringToIndex:2];
    _mainPageAdvertiseURL = [sysParameters objectForKey:@"MainPageAdvertiseURL"];
    _mainDBName = [sysParameters objectForKey:@"mainDBName"];
    
    _signupPageURL = [sysParameters objectForKey:@"SignupPageURL"];
    _paymentPageURL = [NSString stringWithFormat:@"%@", [sysParameters objectForKey:@"PaymentPageURL"]];
    _purchaseVerifyURL = [sysParameters objectForKey:@"PurchaseVerifyURL"];
    _updatePushNotificationTokenURL = [sysParameters objectForKey:@"UpdatePushNotificationTokenURL"];
    _FBShareNotificationURL = [sysParameters objectForKey:@"FBShareNotificationURL"];
    _appStoreURL = [sysParameters objectForKey:@"AppStoreURL"];
    _forgotPasswordURL = [sysParameters objectForKey:@"ForgotPasswordURL"];
    _openProjectURL = [sysParameters objectForKey:@"OpenProjectURL"];
    _checkSubscriptionURL = [sysParameters objectForKey:@"CheckSubscriptionURL"];
    
    _authorityData = [[Authority alloc] init];
    _authorityData.insession = NO;
    _authorityData.eod_new_target = NO;
    _authorityData.eod_check_all = NO;
    _authorityData.strategy_alert = NO;
    _authorityData.port_relate_kline = NO;
    _authorityData.journal_relate_kline = NO;
    _authorityData.press_support = NO;
    _authorityData.adv_on = FSAdvertiseBannerTypeNone;
    _authorityData.portfolio_quota = 50;
    
    
    if ([_lang isEqualToString:@"us"]) {
        _marketVersion = FSMarketVersionUS;
    } else if ([_lang isEqualToString:@"cn"]) {
        _marketVersion = FSMarketVersionCN;
    } else if ([_lang isEqualToString:@"tw"]) {
        _marketVersion = FSMarketVersionTW;
    }
    
    NSLog(@"%@", sysParameters);
}

+ (NSString *)uuid {
    KeychainItemWrapper *keyChainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"UUID" accessGroup:nil];
    NSString *uuid = [keyChainItem objectForKey:(__bridge id)kSecAttrAccount];
    if ([uuid length] == 0) {
        uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [keyChainItem setObject:uuid forKey:(__bridge id)kSecAttrAccount];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[uuid substringToIndex:24] forKey:@"UUID1"];
    [defaults setObject:[uuid substringWithRange:NSMakeRange(24, 12)] forKey:@"UUID2"];
    [defaults synchronize];
    
    return uuid;
}

+ (NSString *)manufacturingFactory {
    return @"apple";
}

+ (NSString *)machineModelNumber {
    return [FSUtility getSysInfoByName:"hw.machine"];
}

+ (NSString *)operatingSystemVersion {
    return [NSString stringWithFormat:@"%@ %@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
}

+ (NSString *)appFullVersion {
    return [NSString stringWithFormat:@"%@.%@", [FSFonestock appVersion], [FSFonestock appBuildNo]];
}

+ (NSString *)appClientInfo {
    
    return [NSString stringWithFormat:@"Fonestock-iPhone-%@_%@_V%@_%@",
            [[FSFonestock sharedInstance] appId],
            [[[[FSFonestock sharedInstance] appId] substringToIndex:1] uppercaseString],
            [FSFonestock appVersion],
            [FSFonestock appBuildNo]];
}

+ (NSString *)appName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

+ (NSString *)appDisplayName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

+ (NSString *)appVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)appBuildNo {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

+ (NSString *)appBundleId {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

+ (NSString *)appBundleFilePath:(NSString *)filename {
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    return filePath;
}

- (NSString *)appMainDatabaseFilePath {
    NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [cachesDirectory stringByAppendingPathComponent:_mainDBName];
    return dbPath;
}

- (NSString *)appMainDatabaseBundleFilePath {
    NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:_mainDBName];
    return dbPath;
}

- (BOOL)checkPermission:(FSPermissionType)type showAlertViewToShopping:(BOOL)show {
    
    BOOL check = [self checkPermission:type];
    if (!check && show) {
        
        if ([[[FSDataModelProc sharedInstance] mainSocket] isConnected]) {
            alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"提示收費", @"Launcher", nil)
                                                   message:NSLocalizedStringFromTable(@"如果需要使用該功能，請前往付費", @"Launcher", nil)
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"Launcher", nil)
                                         otherButtonTitles:NSLocalizedStringFromTable(@"前往付費", @"Launcher", nil), nil];
            [alertView show];
            
        }
        else {
            alertView = [[UIAlertView alloc] initWithTitle:@""
                                                   message:@"請登入"
                                                  delegate:nil
                                         cancelButtonTitle:@"確認"
                                         otherButtonTitles:nil];
            [alertView show];
            
        }
        return NO;
        
    }
    return check;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        [_launcherTarget moveToPaymentView];
    }
}

-(void)setTarget:(FSLauncherPageViewController *)aTarget
{
    _launcherTarget = aTarget;
}

- (BOOL)checkPermission:(FSPermissionType)type {
    return YES;
    
    if (![[[FSDataModelProc sharedInstance] mainSocket] isConnected]) {
        return NO;
    }
    switch (type) {
        case FSPermissionTypePatternSearchInSession:
            return _authorityData.insession;
            
        case FSPermissionTypeEODNewTarget:
            return _authorityData.eod_new_target;
            
        case FSPermissionTypeEODCheckALL:
            return _authorityData.eod_check_all;
            
        case FSPermissionTypeStrategyAlert:
            return _authorityData.strategy_alert;
            
        case FSPermissionTypeJournalRelateKline:
            return _authorityData.journal_relate_kline;
            
        case FSPermissionTypePortRelateKLine:
            return _authorityData.port_relate_kline;
            
        case FSPermissionTypePressSupport:
            return _authorityData.press_support;
            
        default:
            break;
    }
}

- (BOOL)checkNeedShowAdvertise {
//    if (_authorityData.adv_on == FSAdvertiseBannerTypeAdmob) {
//        return YES;
//    }
    return NO;
}

- (BOOL)twoStockMode {
    
    // 讀取是否用雙股走勢
    
    NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
    NSString *fileName = @"TechViewDefaultIndicator.plist";
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSMutableDictionary *techViewInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    return [[techViewInfo objectForKey:@"stockCompareValue"] boolValue];
}

- (void)setTwoStockMode:(BOOL)twoStockMode {
    
    NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
    NSString *fileName = @"TechViewDefaultIndicator.plist";
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSMutableDictionary *techViewInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    [techViewInfo setObject:[NSNumber numberWithBool:twoStockMode] forKey:@"stockCompareValue"];
    [techViewInfo writeToFile:path atomically:YES];
}


@end

@implementation Authority
@end
