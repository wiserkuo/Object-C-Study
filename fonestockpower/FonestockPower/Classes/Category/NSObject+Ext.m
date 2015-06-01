//
//  NSObject+Ext.m
//  FonestockPower
//
//  Created by Connor on 14/4/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "NSObject+Ext.h"

@implementation NSObject (Ext)

+ (NSString *)classCallerName {
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:2];
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    
    if ([array count] > 3) {
        return [array objectAtIndex:3];
    }
    
    //    NSLog(@"Stack = %@", [array objectAtIndex:0]);
    //    NSLog(@"Framework = %@", [array objectAtIndex:1]);
    //    NSLog(@"Memory address = %@", [array objectAtIndex:2]);
    //    NSLog(@"Class caller = %@", [array objectAtIndex:3]);
    //    NSLog(@"Function caller = %@", [array objectAtIndex:4]);
    //    NSLog(@"Line caller = %@", [array objectAtIndex:5]);
    
    return nil;
}
@end
