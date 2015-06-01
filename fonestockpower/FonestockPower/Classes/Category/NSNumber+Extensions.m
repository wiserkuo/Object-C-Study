//
//  NSNumber+Extensions.m
//  Bullseye
//
//  Created by Connor on 13/9/2.
//
//

#import "NSNumber+Extensions.h"

@implementation NSNumber (Extensions)

- (NSDate *)uint16ToDate {
    
	NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
    
    int val = [self intValue];
    dateComponent.year = (val >> 9) + 1960;
    dateComponent.month = (val >> 5) & 0xF;
    dateComponent.day = val & 0x1F;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *date = [calendar dateFromComponents:dateComponent];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *now = [date dateByAddingTimeInterval:interval];

    return now;
}

- (NSDate *)uint16ToDateForCompany {
    
    NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
    
    int val = [self intValue];
    dateComponent.year = (val >> 9) + 1900;
    dateComponent.month = (val >> 5) & 0xF;
    dateComponent.day = val & 0x1F;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *date = [calendar dateFromComponents:dateComponent];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *now = [date dateByAddingTimeInterval:interval];
    
    return now;
}

- (NSDate *)uint16ToTime {
    
	NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
    
    int val = [self intValue];
    dateComponent.hour = (val >> 16) ;
    dateComponent.minute = (val >> 8) & 0xFF;
    dateComponent.second = val & 0xFF;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *date = [calendar dateFromComponents:dateComponent];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *now = [date dateByAddingTimeInterval:interval];
    
    return now;
}



@end
