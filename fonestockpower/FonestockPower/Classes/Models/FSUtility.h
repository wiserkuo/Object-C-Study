//
//  FSUtility.h
//  FonestockPower
//
//  Created by Connor on 14/3/19.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

@interface FSUtility : NSObject

+ (BOOL)isMutitaskingSupported;
+ (NSString *)appMarket;

+ (NSString *)getSysInfoByName:(char *)typeSpecifier;
+ (BOOL)isGraterThanSupportVersion:(float)version;
@end
