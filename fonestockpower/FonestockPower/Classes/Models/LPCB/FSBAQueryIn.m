//
//  FSBAQueryIn.m
//  FonestockPower
//
//  Created by Connor on 14/7/30.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSBAQueryIn.h"
#import "DecodeProtocol.h"
#import "FSBAIn.h"

@interface FSBAQueryIn(){
    NSMutableArray * BAArray;
}

@end

@implementation FSBAQueryIn

- (id)init
{
	if(self = [super init])
	{
		BAArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode {
    UInt8 *ptr = body;
    _securityNO = commodity;
    int count = *ptr++;
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    int baNote;
    for (int k=0; k<count; k++) {
        UInt8 *tmPtr = ptr;
        
        NSString * identCodeSymbol = [CodingUtil getShortStringFormatByBuffer:&tmPtr needOffset:YES];
        identCodeSymbol = [identCodeSymbol stringByReplacingOccurrencesOfString:@":" withString:@" "];
        int dataLength = *tmPtr ++;
        
        NSMutableArray * baBidArray = [[NSMutableArray alloc]init];
        NSMutableArray * baAskArray = [[NSMutableArray alloc]init];
        
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
        
        
        FSSnapshot * snapShot = [dataModal.portfolioTickBank getSnapshotBvalueFromIdentCodeSymbol:identCodeSymbol];
        
        snapShot.BABidArray = baBidArray;
        snapShot.BAAskArray = baAskArray;
        
        [dataModal.portfolioTickBank performSelector:@selector(updateEquitySnapshot:) withObject:snapShot];

        ptr += dataLength + 5;
    }

}

@end
