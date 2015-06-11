//
//  FSDateFormat.m
//  FonestockPower
//
//  Created by Connor on 14/8/7.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSDateFormat.h"

@implementation FSDateFormat
@synthesize date16;

- (instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset {
    if (self = [super init]) {
        UInt8 *ptr = *sptr;
        
        date16 = [CodingUtil getUInt16:ptr];
        
        if (needOffset) {
            *sptr += 2;
        }
    }
    return self;
}

- (NSDate *)date {
	NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
    dateComponent.year = (date16 >> 9) + 1960;
    dateComponent.month = (date16 >> 5) & 0xF;
    dateComponent.day = date16 & 0x1F;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDate *date = [calendar dateFromComponents:dateComponent];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *now = [date dateByAddingTimeInterval:interval];
    
    return now;
}

- (NSString *)dateFormatToString:(NSString *)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:string];
    return [dateFormatter stringFromDate:[self date]];
}
@end
