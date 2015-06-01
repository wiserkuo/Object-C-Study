//
//  FSBTimeFormat.h
//  FonestockPower
//
//  Created by Connor on 14/8/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSBTimeFormat : NSObject <NSCopying>{
    int _hours;
    int _minutes;
    int _seconds;
    int _sn;
}

- (instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset;
- (instancetype)initWithHours:(int)hours minutes:(int)minutes seconds:(int)seconds sn:(int)sn;
- (instancetype)initWithTimeFormatUInt16:(UInt16)time;
- (void)setBuffer:(char **)buf needOffset:(BOOL)needOffset;
- (NSNumber *)timeValue;
- (NSString *)timeString;
- (int)absoluteMinutesTime;
- (void)timeOffsetWithAddHours:(int)hours minutes:(int)minutes seconds:(int)seconds sn:(int)sn;
@end
