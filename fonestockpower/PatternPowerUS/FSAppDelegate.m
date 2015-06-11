//
//  FSAppDelegate.m
//  PatternPowerUS
//
//  Created by Connor on 14/3/28.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSAppDelegate.h"

#import "FSDataModelProc.h"
#import "FSRootViewController.h"
#import "FSPointsAuthCenter.h"
#import "FSDatabaseAgent.h"
#import "FSNavigationViewController.h"
#import <Crashlytics/Crashlytics.h>
#import "FSFonestock.h"
#import "FSNavigationViewController.h"
#import "GADBannerView.h"
#import "EODTargetController.h"
#import "FSLauncherPageViewController.h"
#import "URLParser.h"
#import "FSLoginViewController.h"
#import "JCNotificationCenter.h"
#import "JCNotificationBannerPresenterIOS7Style.h"

#import "KeychainItemWrapper.h"

@interface FSAppDelegate()<UIApplicationDelegate> {
    FSDataModelProc *dataModelProc;
    UIBackgroundTaskIdentifier bgTask;
    GADBannerView *bannerView_;
}

@end

@implementation FSAppDelegate

- (void) clearNotifications
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"%@", [CodingUtil fonestockDocumentsPath]);
    [self checkResetData];
    
    [Crashlytics startWithAPIKey:@"a5806811059e08ec646d426a7a2b1ea5939df3d3"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    dataModelProc = [FSDataModelProc sharedInstance];
    [dataModelProc start];
    [dataModelProc waitUntilReady];
    
    _rootViewNavController = [[FSNavigationViewController alloc] initWithRootViewController:[[FSRootViewController alloc] init]];
    self.window.rootViewController = _rootViewNavController;
    
// 推播通知用
    [self clearNotifications];

#if !TARGET_IPHONE_SIMULATOR
    
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    
    } else {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
    
#endif
    return YES;
}

/*
 推播通知delegate, 取得token
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *deviceTokenString = [NSString stringWithFormat:@"%@", deviceToken];
    deviceTokenString = [deviceTokenString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[NSUserDefaults standardUserDefaults] setValue:deviceTokenString forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"account"];
    
    if (account != nil) {
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        [dataModel.pushNotificationCenter updatePushTokenWithDeviceType:@"apple" deviceId:[FSFonestock uuid] token:deviceTokenString account:account app_id:[FSFonestock sharedInstance].appId];
    }
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"error %@",error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
#ifdef SERVER_SYNC
    for(id key in userInfo){
        NSLog(@"Key: %@, value: %@",key, [userInfo objectForKey:key]);
    }
    UIViewController *vvv;
    for(id view in self.rootViewNavController.viewControllers){
        if([view isKindOfClass:[FSLauncherPageViewController class]]){
            vvv = view;
            break;
        }
    }
    [self.rootViewNavController popToViewController:vvv animated:NO];
    
    UIViewController *view = [[EODTargetController alloc] init];
    [self.rootViewNavController pushViewController:view animated:NO];
    
#endif
    [self clearNotifications];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    UIApplication *app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self checkResetData];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self checkResetData];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)checkResetData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[FSFonestock appFullVersion] forKey:@"Version"];
    if ([[defaults objectForKey:@"ClearData"]boolValue]){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:[CodingUtil techLineDataDirectoryPath]]){
            [fileManager removeItemAtPath:[CodingUtil techLineDataDirectoryPath] error:nil];
        }
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        dataModel.isRejectReLogin = YES;
        [defaults setObject:@NO forKey:@"ClearData"];
        [defaults synchronize];
        
//        [[[FSDataModelProc sharedInstance] accountManager] removeAllUserInformationData];
//        KeychainItemWrapper *keyChainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"USER_INFORMATION" accessGroup:nil];
//        [keyChainItem resetKeychainItem];
        [NSUserDefaults resetStandardUserDefaults];
        
        [_rootViewNavController popToRootViewControllerAnimated:NO];
    }
}

// APP URL啟動
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    URLParser *urlParser = [[URLParser alloc] initWithURL:url];
    if ([[url scheme] isEqualToString:[FSFonestock sharedInstance].appId] && [[url path] isEqualToString:@"/openloginpage"]) {
        NSString *account = [urlParser valueForVariable:@"account"];
        
        if (account != nil) {
            account = [account stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        [_rootViewNavController popToRootViewControllerAnimated:NO];
        FSLoginViewController *loginViewController = [[FSLoginViewController alloc] initWithAccount:account AndPassword:@""];
        [_rootViewNavController pushViewController:loginViewController animated:NO];
    }
    return YES;
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
#ifdef SERVER_SYNC
    [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOS7Style new];
    [JCNotificationCenter
     enqueueNotificationWithTitle:@"圖是力"
     message:notification.alertBody
     tapHandler:^{
         //
     }];
#endif
}

@end
