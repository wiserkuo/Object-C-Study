//
//  FSAppDelegate.m
//  PatternPowerCN
//
//  Created by Connor on 14/3/28.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSAppDelegate.h"
#import "FSRootViewController.h"
#import "FSLoginViewController.h"
#import "FSLauncherViewController.h"
#import <Crashlytics/Crashlytics.h>

@interface FSAppDelegate() {
    FSDataModelProc *dataModelProc;
}
@end

@implementation FSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
        NSLog(@"%@", [CodingUtil fonestockDocumentsPath]);
    [Crashlytics startWithAPIKey:@"a5806811059e08ec646d426a7a2b1ea5939df3d3"];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    dataModelProc = [FSDataModelProc sharedInstance];
    [dataModelProc start];
    
    _rootViewNavController = [[FSNavigationViewController alloc] initWithRootViewController:[[FSRootViewController alloc] init]];
    self.window.rootViewController = self.rootViewNavController;
    
    @try {
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception description]);
    }
    @finally {
        
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
