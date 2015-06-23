//
//  FSReferenceIn.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/6/4.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSReferenceIn.h"
#import "DecodeProtocol.h"

@interface FSReferenceIn () <DecodeProtocol>

@end

@implementation FSReferenceIn

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{
    UInt8 *ptr = body;
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    FSSnapshot *snapShot = [dataModal.portfolioTickBank getSnapshotBvalue:commodity];
    
    UInt16 mask = [CodingUtil getUInt16:&ptr needOffset:YES];
    
    snapShot.reference_price = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
    snapShot.trading_date = [[FSDateFormat alloc] initWithByte:&ptr needOffset:YES];
    
    FSBValueFormat *previousOpenInterest;
    FSBValueFormat *tradingUnit;
    if (mask & 1 << 0) {
        snapShot.pre_volume = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
    }
    if (mask & 1 << 1) {
        snapShot.top_price = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
        snapShot.bottom_price = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
    }
    if (mask & 1 << 2) {
        previousOpenInterest = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
    }
    if (mask & 1 << 3) {
        ptr += 1;
    }
    if (mask & 1 << 4) {
        ptr += 1;
    }
    if (mask & 1 << 5) {
        tradingUnit = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
    }
    
    
    [dataModal.portfolioTickBank performSelector:@selector(updateEquitySnapshot:) onThread:dataModal.thread withObject:snapShot waitUntilDone:NO];
}



@end

