//
//  NSDate+Extensions.m
//  Bullseye
//
//  Created by Connor on 13/8/30.
//
//

#import "NSDate+Extensions.h"

#define UTCFormatString @"yyyy-MM-dd'T'HH:mm:ss'Z'"

@implementation NSDate (Extensions)


#pragma mark --
#pragma mark UTC
+ (NSDate *)dateFromUTCString:(NSString *)dateString {
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    [timeFormatter setDateFormat:UTCFormatString];
    
    return [timeFormatter dateFromString:dateString];
}

+ (NSString *)UTCStringFromDate:(NSDate *)date {
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    timeFormatter.dateFormat = UTCFormatString;
    
    return [timeFormatter stringFromDate:date];
}

#pragma mark --
#pragma mark SERVER FORMAT

- (UInt16)uint16Value {

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comp = [calendar components:calendarUnit fromDate:self];
    
    UInt16 newDate = 0;
	newDate += (comp.year - 1960) << 9;
	newDate += comp.month << 5;
	newDate += comp.day;
    
	return newDate;
}

#pragma mark --
#pragma mark 日期計算

- (NSDate *)dayOffset:(NSInteger)dayOffset {
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:dayOffset];
    
    return [currentCalendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)yearOffset:(NSInteger)yearOffset {
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:yearOffset];
    
    return [currentCalendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)monthOffset:(NSInteger)monthOffset {
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:monthOffset];
    
    return [currentCalendar dateByAddingComponents:components toDate:self options:0];
}

#pragma mark - 日期格式轉換
+ (NSString *)dateStringFormat:(NSString *)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    if ([group isEqualToString:@"us"]) {
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    }else{
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    }
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    NSString *dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}

@end
