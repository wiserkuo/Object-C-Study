//
//  SKDateUtils.m
//  testgcd
//
//  Created by Connor on 13/7/9.
//  Copyright (c) 2013年 Connor. All rights reserved.
//

#import "SKDateUtils.h"

@implementation SKDateUtils

- (SKDateUtils *)initWithDate:(NSDate *)baseDate {
    self = [super init];
    if (self) {
        self.baseDate = baseDate;
    }
    return self;
}

- (SKDateUtils *)initWithDateUInt16:(UInt16)baseDate {
    self = [super init];
    if (self) {
        NSDateComponents *dateComponent = [NSDateComponents new];
        dateComponent.year = (baseDate >> 9) + 1960;
        dateComponent.month = (baseDate >> 5) & 0xF;
        dateComponent.day = baseDate & 0x1F;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDate *a = [calendar dateFromComponents:dateComponent];
        self.baseDate = a;
    }
    return self;
}


+ (NSDate *)getCurrentDateTime {
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *now = [date dateByAddingTimeInterval:interval];
    return now;
}

+ (NSDate *)transferDateTimeToSystemTimeZone:(NSDate *)date {
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *now = [date dateByAddingTimeInterval:interval];
    return now;
}

- (NSString *)getCustomDate:(NSDate *)beginningOfDay getEndingOfDay:(NSDate *)endingOfDay format:(NSString *)format {
    
    
    if (format != nil) {
        
        NSDate *startDate = [SKDateUtils transferDateTimeToSystemTimeZone:beginningOfDay];
        NSDate *endDate = [SKDateUtils transferDateTimeToSystemTimeZone:endingOfDay];
        
        NSString *beginningOfDay_str = [SKDateUtils dateToStrByFormat:startDate format:format];
        NSString *endingOfDay_str = [SKDateUtils dateToStrByFormat:endDate format:format];
        NSString *retVal = [NSString stringWithFormat:@"%@~%@", beginningOfDay_str, endingOfDay_str];
        return retVal;
    }
    
    return nil;
}

- (NSString *)getBeginningOfWeek:(NSDate **)beginningOfWeek getEndingOfWeek:(NSDate **)endingOfWeek format:(NSString *)format {
    
    NSDate *currentDateTime = self.baseDate;
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [currentCalendar components:NSWeekdayCalendarUnit|NSWeekCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDateTime];
    
    *beginningOfWeek = [SKDateUtils getDateByDayOffset:currentCalendar date:currentDateTime dayOffset:1-[weekdayComponents weekday]];
    *endingOfWeek = currentDateTime;
    
    if (format != nil) {
        
        NSDate *startDate = [SKDateUtils transferDateTimeToSystemTimeZone:*beginningOfWeek];
        NSDate *endDate = [SKDateUtils transferDateTimeToSystemTimeZone:*endingOfWeek];
        
        NSString *beginningOfWeek_str = [SKDateUtils dateToStrByFormat:startDate format:format];
        NSString *endingOfWeek_str = [SKDateUtils dateToStrByFormat:endDate format:format];
        NSString *retVal = [NSString stringWithFormat:@"%@~%@", beginningOfWeek_str, endingOfWeek_str];
        return retVal;
    }
    
    return nil;
}

- (NSString *)getpreviousOfBeginningOfWeek:(NSDate **)previousOfBeginningOfWeek getEndingOfWeek:(NSDate **)previousOfEndingOfWeek format:(NSString *)format {
    NSDate *currentDateTime = self.baseDate;
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [currentCalendar components:NSWeekdayCalendarUnit|NSWeekCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDateTime];
    
    NSDate *beginningOfWeek = [SKDateUtils getDateByDayOffset:currentCalendar date:currentDateTime dayOffset:1-[weekdayComponents weekday]];
    NSDate *endingOfWeek = [SKDateUtils getDateByDayOffset:currentCalendar date:currentDateTime dayOffset:7-[weekdayComponents weekday]];

    *previousOfBeginningOfWeek = [SKDateUtils getDateByWeekOffset:currentCalendar date:beginningOfWeek weekOffset:-1];
    *previousOfEndingOfWeek = [SKDateUtils getDateByWeekOffset:currentCalendar date:endingOfWeek weekOffset:-1];
    
    if (format != nil) {
        
        NSDate *startDate = [SKDateUtils transferDateTimeToSystemTimeZone:*previousOfBeginningOfWeek];
        NSDate *endDate = [SKDateUtils transferDateTimeToSystemTimeZone:*previousOfEndingOfWeek];
        
        NSString *previousOfBeginningOfWeek_str = [SKDateUtils dateToStrByFormat:startDate format:format];
        NSString *previousOfEndingOfWeek_str = [SKDateUtils dateToStrByFormat:endDate format:format];
        NSString *retVal = [NSString stringWithFormat:@"%@~%@", previousOfBeginningOfWeek_str, previousOfEndingOfWeek_str];
        return retVal;
    }
    
    return nil;
}

- (NSString *)getpreviousOfBeginningOf2Week:(NSDate **)previousOfBeginningOf2Week getEndingOf2Week:(NSDate **)previousOfEndingOf2Week format:(NSString *)format {
    NSDate *currentDateTime = self.baseDate;
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [currentCalendar components:NSWeekdayCalendarUnit|NSWeekCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDateTime];
    
    NSDate *beginningOfWeek = [SKDateUtils getDateByDayOffset:currentCalendar date:currentDateTime dayOffset:1-[weekdayComponents weekday]];
    NSDate *endingOfWeek = [SKDateUtils getDateByDayOffset:currentCalendar date:currentDateTime dayOffset:7-[weekdayComponents weekday]];
    
    *previousOfBeginningOf2Week = [SKDateUtils getDateByWeekOffset:currentCalendar date:beginningOfWeek weekOffset:-2];
    *previousOfEndingOf2Week = [SKDateUtils getDateByWeekOffset:currentCalendar date:endingOfWeek weekOffset:-2];
    
    if (format != nil) {
        
        NSDate *startDate = [SKDateUtils transferDateTimeToSystemTimeZone:*previousOfBeginningOf2Week];
        NSDate *endDate = [SKDateUtils transferDateTimeToSystemTimeZone:*previousOfEndingOf2Week];
        
        NSString *previousOfBeginningOfWeek_str = [SKDateUtils dateToStrByFormat:startDate format:format];
        NSString *previousOfEndingOfWeek_str = [SKDateUtils dateToStrByFormat:endDate format:format];
        NSString *retVal = [NSString stringWithFormat:@"%@~%@", previousOfBeginningOfWeek_str, previousOfEndingOfWeek_str];
        return retVal;
    }
    
    return nil;
}


- (NSString *)getBeginningOfMonth:(NSDate **)_beginningOfMonth_work getEndingOfMonth:(NSDate **)_endingOfMonth_work format:(NSString *)format {
    NSDate *currentDateTime = self.baseDate;
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [currentCalendar components:NSWeekdayCalendarUnit|NSWeekCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDateTime];
    
    NSDate *beginningOfMonth = [SKDateUtils getDateByDayOffset:currentCalendar date:currentDateTime dayOffset:1-[weekdayComponents day]];

    NSDateComponents *testWeekDayDateComponents = [currentCalendar components:NSWeekdayCalendarUnit fromDate:beginningOfMonth];

    NSDate *beginningOfMonth_work;
    if ([testWeekDayDateComponents weekday] == 1) {
        beginningOfMonth_work = [SKDateUtils getDateByDayOffset:currentCalendar date:beginningOfMonth dayOffset:0];
    } else if ([testWeekDayDateComponents weekday] == 7) {
        beginningOfMonth_work = [SKDateUtils getDateByDayOffset:currentCalendar date:beginningOfMonth dayOffset:6];
    } else {
        beginningOfMonth_work = beginningOfMonth;
    }
    

    NSDate *endingOfMonth = currentDateTime;
    NSDateComponents *testDayDateComponents = [currentCalendar components:NSWeekdayCalendarUnit fromDate:currentDateTime];


    NSDate *endingOfMonth_work;
    if ([testDayDateComponents weekday] == 1) {
        endingOfMonth_work = [SKDateUtils getDateByDayOffset:currentCalendar date:endingOfMonth dayOffset:-1];
    } else if ([testDayDateComponents weekday] == 7) {
        endingOfMonth_work = [SKDateUtils getDateByDayOffset:currentCalendar date:endingOfMonth dayOffset:0];
    } else {
        endingOfMonth_work = endingOfMonth;
    }
    
    *_beginningOfMonth_work = beginningOfMonth_work;
    *_endingOfMonth_work = endingOfMonth_work;
    
    if (format != nil) {
        
        NSDate *startDate = [SKDateUtils transferDateTimeToSystemTimeZone:beginningOfMonth_work];
        NSDate *endDate = [SKDateUtils transferDateTimeToSystemTimeZone:endingOfMonth_work];
        
        NSString *beginningOfMonth_work_str = [SKDateUtils dateToStrByFormat:startDate format:format];
        NSString *endingOfMonth_work_str = [SKDateUtils dateToStrByFormat:endDate format:format];
        NSString *retVal = [NSString stringWithFormat:@"%@~%@", beginningOfMonth_work_str, endingOfMonth_work_str];
        return retVal;
    }
    return nil;
}

- (NSString *)getpreviousBeginningOfMonth:(NSDate **)_beginningOfMonth_work getpreviousEndingOfMonth:(NSDate **)_endingOfMonth_work format:(NSString *)format {
    NSDate *currentDateTime = self.baseDate;
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [currentCalendar components:NSWeekdayCalendarUnit|NSWeekCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDateTime];
    
    NSDate *previousMonth = [SKDateUtils getDateByMonthOffset:currentCalendar date:currentDateTime monthOffset:-1];
    
    NSDate *beginningOfMonth = [SKDateUtils getDateByDayOffset:currentCalendar date:previousMonth dayOffset:1-[weekdayComponents day]];
    
    NSDateComponents *testWeekDayDateComponents = [currentCalendar components:NSWeekdayCalendarUnit fromDate:beginningOfMonth];
    
    NSDate *beginningOfMonth_work;
    if ([testWeekDayDateComponents weekday] == 1) {
        beginningOfMonth_work = [SKDateUtils getDateByDayOffset:currentCalendar date:beginningOfMonth dayOffset:0];
    } else if ([testWeekDayDateComponents weekday] == 7) {
        beginningOfMonth_work = [SKDateUtils getDateByDayOffset:currentCalendar date:beginningOfMonth dayOffset:1];
    } else {
        beginningOfMonth_work = beginningOfMonth;
    }
    
    NSDate *endingOfMonth = [SKDateUtils getDateByMonthOffset:currentCalendar date:currentDateTime monthOffset:-1];
    
    NSDateComponents *testDayDateComponents = [currentCalendar components:NSDayCalendarUnit fromDate:endingOfMonth];
    
    NSRange range = [currentCalendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:endingOfMonth];
    NSUInteger numberOfDaysInMonth = range.length;
    
    endingOfMonth = [SKDateUtils getDateByDayOffset:currentCalendar date:endingOfMonth dayOffset:numberOfDaysInMonth-[testDayDateComponents day]];
    
    testDayDateComponents = [currentCalendar components:NSWeekdayCalendarUnit fromDate:endingOfMonth];
    
    
    NSDate *endingOfMonth_work;
    if ([testDayDateComponents weekday] == 1) {
        endingOfMonth_work = [SKDateUtils getDateByDayOffset:currentCalendar date:endingOfMonth dayOffset:-1];
    } else if ([testDayDateComponents weekday] == 7) {
        endingOfMonth_work = [SKDateUtils getDateByDayOffset:currentCalendar date:endingOfMonth dayOffset:0];
    } else {
        endingOfMonth_work = endingOfMonth;
    }
    
    *_beginningOfMonth_work = beginningOfMonth_work;
    *_endingOfMonth_work = endingOfMonth_work;
    
    if (format != nil) {
        
        NSDate *startDate = [SKDateUtils transferDateTimeToSystemTimeZone:beginningOfMonth_work];
        NSDate *endDate = [SKDateUtils transferDateTimeToSystemTimeZone:endingOfMonth_work];
        
        NSString *beginningOfMonth_work_str = [SKDateUtils dateToStrByFormat:startDate format:format];
        NSString *endingOfMonth_work_str = [SKDateUtils dateToStrByFormat:endDate format:format];
        NSString *retVal = [NSString stringWithFormat:@"%@~%@", beginningOfMonth_work_str, endingOfMonth_work_str];
        return retVal;
    }
    return nil;
}


+ (NSDate *)getDateByYMD:(NSCalendar *)calendar year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    return [calendar dateFromComponents:components];
}

+ (NSDate *)getDateByDayOffset:(NSCalendar *)calendar date:(NSDate *)date dayOffset:(NSInteger)dayOffset {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:dayOffset];
    return [calendar dateByAddingComponents:components toDate:date options:0];
}

+ (NSDate *)getDateByWeekOffset:(NSCalendar *)calendar date:(NSDate *)date weekOffset:(NSInteger)weekOffset {
    NSDateComponents *originComponents = [[NSDateComponents alloc] init];
    [originComponents setWeekOfMonth:weekOffset];
    return [calendar dateByAddingComponents:originComponents toDate:date options:0];
}

+ (NSDate *)getDateByMonthOffset:(NSCalendar *)calendar date:(NSDate *)date monthOffset:(NSInteger)monthOffset {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:monthOffset];
    return [calendar dateByAddingComponents:components toDate:date options:0];
}

+ (NSInteger)getLengthOfWeekInMonth:(NSCalendar *)calendar month:(NSInteger)month year:(NSInteger)year {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    
    NSRange range = [calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:[calendar dateFromComponents:components]];
    return range.length;
}

+ (NSInteger)getWeekCountsOf2Dates:(NSCalendar *)calendar fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate {
    NSDateComponents *components = [calendar components:(NSWeekCalendarUnit) fromDate:fromDate toDate:toDate options:0];
    return [components weekOfMonth] + 1;
}

+ (NSString *)dateToStrByFormat:(NSDate *)date format:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}

+ (Boolean)ifInSameMonth:(NSDate *)dateA dateB:(NSDate *)dateB calendar:(NSCalendar *)calendar {
    NSDateComponents *compA = [calendar components:(NSMonthCalendarUnit) fromDate:dateA];
    NSDateComponents *compB = [calendar components:(NSMonthCalendarUnit) fromDate:dateB];
    if ([compA month] == [compB month]) {
        return YES;
    }
    return NO;
}

+ (NSDictionary *)getDateArgs:(NSCalendar *)calendar date:(NSDate *)date {
    NSDateComponents *comp = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit) fromDate:date];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"year", @"month", @"week", @"weekday", @"day", nil] forKeys:[NSArray arrayWithObjects:[NSNumber numberWithInteger:1], [NSNumber numberWithInteger:1], [NSNumber numberWithInteger:1], [NSNumber numberWithInteger:1], [NSNumber numberWithInteger:1], nil]];
    
    [dict setObject:[NSNumber numberWithInteger:[comp year]] forKey:@"year"];
    [dict setObject:[NSNumber numberWithInteger:[comp month]] forKey:@"month"];
    [dict setObject:[NSNumber numberWithInteger:[comp weekOfMonth]] forKey:@"week"];
    [dict setObject:[NSNumber numberWithInteger:[comp weekday]] forKey:@"weekday"];
    [dict setObject:[NSNumber numberWithInteger:[comp day]] forKey:@"day"];
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (NSInteger)getWeekOrderOfMonth:(NSCalendar *)calendar date:(NSDate *)date {
    NSDictionary *dateDict = [self getDateArgs:calendar date:date];
    NSDate *firstDate = [self getDateByYMD:calendar year:[[dateDict objectForKey:@"year"] integerValue] month:[[dateDict objectForKey:@"month"] integerValue] day:1];
    return [self getWeekCountsOf2Dates:calendar fromDate:firstDate toDate:date];
}

+ (NSInteger)getFirstWeekOrderOfMonth:(NSCalendar *)calendar date:(NSDate *)date {
    NSDictionary *dateDict = [self getDateArgs:calendar date:date];
    NSDate *firstDate = [self getDateByYMD:calendar year:[[dateDict objectForKey:@"year"] integerValue] month:[[dateDict objectForKey:@"month"] integerValue] day:1];
    NSDictionary *firstDict = [self getDateArgs:calendar date:firstDate];
    return [[firstDict objectForKey:@"week"] integerValue];
}

@end