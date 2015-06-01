//
//  FSBAIn.m
//  FonestockPower
//
//  Created by Neil on 2014/11/6.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSBAIn.h"
#import "BADataIn.h"

@implementation FSBAIn

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode {
    UInt8 *tmPtr = body;
    NSMutableArray * baBidArray = [[NSMutableArray alloc]init];
    NSMutableArray * baAskArray = [[NSMutableArray alloc]init];
    int baNote;
    baNote = *tmPtr++;
    
    int bidCount = *tmPtr++;
    
    for (int i =0; i<bidCount; i++) {
        FSBValueFormat * bidPrice = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        FSBValueFormat * bidVolume = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        
        BAData_bValue * baData = [[BAData_bValue alloc]init];
        baData->bidPrice = bidPrice.calcValue;
        baData->bidVolume = bidVolume.calcValue;
        
        [baBidArray addObject:baData];
    }
    
    int askCount = *tmPtr++;
    
    for (int i =0; i<askCount; i++) {
        FSBValueFormat * askPrice = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        FSBValueFormat * askVolume = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        
        BAData_bValue * baData = [[BAData_bValue alloc]init];
        baData->askPrice = askPrice.calcValue;
        baData->askVolume = askVolume.calcValue;
        
        [baAskArray addObject:baData];
    }

    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    FSSnapshot * snapShot = [dataModal.portfolioTickBank getSnapshotBvalue:commodity];
    
    snapShot.BABidArray = baBidArray;
    snapShot.BAAskArray = baAskArray;
    
    [dataModal.portfolioTickBank performSelector:@selector(updateEquitySnapshot:) withObject:snapShot];
    
}

@end

@implementation BAData_bValue


@end
