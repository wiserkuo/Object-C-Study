//
//  FSTickData.m
//  FonestockPower
//
//  Created by Connor on 14/8/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSTickData.h"

@implementation FSTickData
@synthesize accumulated_volume, ask, ask_volume, bid, bid_volume, identCodeSymbol, last, time, volume, queryType;
@synthesize indexValue, dealValue, dealVolume, dealRecord, bidRecord, askRecord, bidVolume, askVolume, up, down, unchanged, topCount, bottomCount;

- (instancetype)initWithByte:(UInt8 *)ptr tickType:(FSTickType)tickType {
    if (self = [super init]) {
        if (tickType == FSTickType3) {
            UInt16 mask = [CodingUtil getUInt16:ptr];
            ptr += 2;
            
            time = [[FSBTimeFormat alloc] initWithByte:&ptr needOffset:YES];
            ptr += 1;
            
            if (mask & 1 << 0) {
                last = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            }
            if (mask & 1 << 1) {
                accumulated_volume = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            }
            if (mask & 1 << 2) {
                volume = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            }
            if (mask & 1 << 3) {
                bid = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
                ask = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
                
            }
            if (mask & 1 << 4) {
                bid_volume = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
                ask_volume = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            }
        }
        
        else if (tickType == FSTickType4) {
            UInt16 mask = [CodingUtil getUInt16:ptr];
            ptr += 2;
            
            if (mask & 1 << 0) {
                time = [[FSBTimeFormat alloc] initWithByte:&ptr needOffset:YES];
                indexValue = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            }
            if (mask & 1 << 1) {
                dealValue = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            }
            if (mask & 1 << 2) {
                dealVolume = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            }
            if (mask & 1 << 3) {
                dealRecord = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
                bidRecord = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
                askRecord = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
                bidVolume = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
                askVolume = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
                
            }
            if (mask & 1 << 4) {
                up = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
                down = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
                unchanged = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            }
            if (mask & 1 << 5) {
                topCount = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
                bottomCount = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            }

        }
        
        else {
            
        }
        
    }
    return self;
}
@end
