//
//  FSTickData.h
//  FonestockPower
//
//  Created by Connor on 14/8/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FSTickType) {
    FSTickType3 = 3,    // tick
    FSTickType4 = 4     // market index tick
};

typedef NS_ENUM(NSUInteger, FSTickReceiveType) {
    FSTickReceiveTypePush,
    FSTickReceiveTypeQuery
};

@interface FSTickData : NSObject {

}

@property NSString *identCodeSymbol;
@property UInt32 securityNumber;
@property FSTickType type;

@property FSBTimeFormat *time;
@property FSBValueFormat *last;
@property FSBValueFormat *accumulated_volume;
@property FSBValueFormat *volume;
@property FSBValueFormat *bid;
@property FSBValueFormat *ask;
@property FSBValueFormat *bid_volume;
@property FSBValueFormat *ask_volume;
@property FSTickReceiveType queryType;

//market Index
@property FSBValueFormat *indexValue;
@property FSBValueFormat *dealValue;
@property FSBValueFormat *dealVolume;
@property FSBValueFormat *dealRecord;
@property FSBValueFormat *bidRecord;
@property FSBValueFormat *askRecord;
@property FSBValueFormat *bidVolume;
@property FSBValueFormat *askVolume;
@property FSBValueFormat *up;
@property FSBValueFormat *down;
@property FSBValueFormat *unchanged;
@property FSBValueFormat *topCount;
@property FSBValueFormat *bottomCount;

- (instancetype)initWithByte:(UInt8 *)sptr tickType:(FSTickType)tickType;

@end
