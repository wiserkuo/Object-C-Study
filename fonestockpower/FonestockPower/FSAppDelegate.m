//
//  FSAppDelegate.m
//  FonestockPower
//
//  Created by Connor on 14/3/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSAppDelegate.h"
#import "FSDataModelProc.h"
#import "FSUtility.h"
#import "FSRootViewController.h"
#import "FSLoginViewController.h"
#import "FSLauncherViewController.h"

@interface FSAppDelegate()
@property (nonatomic, strong) FSDataModelProc *dataModel;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) NSTimer *myTimer;
@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@end

@implementation FSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    _dataModel = [[FSDataModelProc alloc] init];
    [_dataModel start];
    
    [_dataModel waitUntilReady];
    
    FSLauncherViewController *basedViewController = [[FSLauncherViewController alloc] init];
    _navigationController = [[UINavigationController alloc] initWithRootViewController:basedViewController];
    self.window.rootViewController = _navigationController;
    NSLog(@"%@", [FSUtility appMarket]);
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ([FSUtility isMutitaskingSupported] == NO) {
        return;
    }
    
    self.myTimer =
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector:@selector(timerMethod:)
                                   userInfo:nil
                                    repeats:YES];
    
    self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTask];
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid){
        [self endBackgroundTask];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)rund {
    NSLog(@"GOOD");
}
- (void) timerMethod:(NSTimer *)paramSender {
    NSTimeInterval backgroundTimeRemaining =
    [[UIApplication sharedApplication] backgroundTimeRemaining];
    if (backgroundTimeRemaining == DBL_MAX){
        NSLog(@"Background Time Remaining = Undetermined");
    } else {
        NSLog(@"Background Time Remaining = %.02f Seconds",
              backgroundTimeRemaining);
    }
}
- (void)endBackgroundTask {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    __weak FSAppDelegate *weakSelf = self;
    dispatch_async(mainQueue, ^(void) {
        FSAppDelegate *strongSelf = weakSelf;
        if (strongSelf != nil){
            [strongSelf.myTimer invalidate];
            [[UIApplication sharedApplication]
             endBackgroundTask:self.backgroundTaskIdentifier];
            strongSelf.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
    });
}

@end
