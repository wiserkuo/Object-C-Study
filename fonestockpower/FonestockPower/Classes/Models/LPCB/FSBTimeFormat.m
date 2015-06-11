//
//  FSBTimeFormat.m
//  FonestockPower
//
//  Created by Connor on 14/8/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSBTimeFormat.h"

@implementation FSBTimeFormat

- (id)copyWithZone:(NSZone *)zone {
    FSBTimeFormat *copy = [[FSBTimeFormat allocWithZone: zone] initWithHours:_hours minutes:_minutes seconds:_seconds sn:_sn];
    return copy;
}

- (instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset {
    if (self = [super init]) {
        UInt8 *ptr = *sptr;
        _hours = *ptr;
        _minutes = *(ptr + 1);
        _seconds = *(ptr + 2);
        _sn = *(ptr + 3);
        
        if (needOffset) {
            *sptr += 4;
        }
    }
    return self;
}

- (instancetype)initWithHours:(int)hours minutes:(int)minutes seconds:(int)seconds sn:(int)sn {
    if (self = [super init]) {
        _hours = hours;
        _minutes = minutes;
        _seconds = seconds;
        _sn = sn;
    }
    return self;
}

- (instancetype)initWithTimeFormatUInt16:(UInt16)time {
    if (self = [super init]) {
        _hours = time / 60;
        _minutes = time % 60;
        _seconds = 0;
        _sn = 0;
    }
    return self;
}

- (void)setBuffer:(char **)buf needOffset:(BOOL)needOffset {
    char *ptr = *buf;
    
    *(ptr) = _hours;
    *(ptr + 1) = _minutes;
    *(ptr + 2) = _seconds;
    *(ptr + 3) = _sn;
    
    if (needOffset) {
        *buf += 4;
    }
}

- (NSNumber *)timeValue {
    return [NSNumber numberWithDouble:_hours * 60 * 60 + _minutes * 60 + _seconds + _sn * 0.001];
}

- (NSString *)timeString {
    return [NSString stringWithFormat:@"%02d:%02d", _hours, _minutes];
}

- (int)absoluteMinutesTime {
    return _hours * 60 + _minutes;
}


- (void)timeOffsetWithAddHours:(int)hours minutes:(int)minutes seconds:(int)seconds sn:(int)sn {
    _seconds += seconds;
    _minutes += minutes;
    _hours += hours;
    _sn += sn;
    
    if (_seconds >= 60) {
        _minutes += _seconds / 60;
        _seconds = _seconds % 60;
    }
    
    if (_minutes >= 60) {
        _hours += _minutes / 60;
        _minutes = _minutes % 60;
    }
}

//- (BOOL)isEqualTime:(FSBTimeFormat *)compareTimeFormat {
//    if (_hours == compareTimeFormat.hours && _minutes == compareTimeFormat.minutes && _seconds == compareTimeFormat.seconds) {
//        return YES;
//    }
//    return NO;
//}

@end
