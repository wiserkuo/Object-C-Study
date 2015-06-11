//
//  FSUtility.m
//  FonestockPower
//
//  Created by Connor on 14/3/19.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSUtility.h"
#import <sys/sysctl.h>

@implementation FSUtility

+ (BOOL)isMutitaskingSupported {
    BOOL result = NO;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
        result = [[UIDevice currentDevice] isMultitaskingSupported];
    }
    return result;
}

+ (NSString *)appMarket {
    return nil;
}

+ (NSString *)appName {
    return [FSUtility appMarket];
}

#pragma mark sysctlbyname utils
+ (NSString *)getSysInfoByName:(char *)typeSpecifier {
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}


+ (BOOL)isGraterThanSupportVersion:(float)version {
    if ([(NSNumber *)[[UIDevice currentDevice] systemVersion] floatValue] >= version) {
        return YES;
    }
    return NO;
}

@end
