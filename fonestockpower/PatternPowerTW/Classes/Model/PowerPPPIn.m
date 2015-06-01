//
//  PowerPPPIn.m
//  FonestockPower
//
//  Created by CooperLin on 2014/11/17.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "PowerPPPIn.h"

@implementation PowerPPPIn

-(id)init
{
    if(self = [super init]){
        buyData = [[NSMutableArray alloc] init];
        sellData = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
    NSLog(@"i had received some data");
    
    UInt8 *tmpPtr = body;
    
    //buy share branch data
    UInt8 buyShareCount;

    //sell share branch data
    UInt8 sellShareCount;
    
    identCode = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    symbol = [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
    startDate = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    endDate = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    price = [[FSBValueFormat alloc]initWithByte:&tmpPtr needOffset:YES];
    
    buyShareCount = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
    for(int i = 0; i < buyShareCount; i++){
        BuyStuff *bs = [[BuyStuff alloc] init];
        bs.buyBrokerBranchId = [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
        bs.buyShare = [[FSBValueFormat alloc] initWithByte:&tmpPtr needOffset:YES];
        if(i < 20){
            [buyData addObject:bs];
        }
    }
    
    sellShareCount = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
    for(int i = 0; i < sellShareCount; i++){
        SellStuff *ss = [[SellStuff alloc] init];
        ss.sellBrokerBranchId = [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
        ss.sellShare = [[FSBValueFormat alloc] initWithByte:&tmpPtr needOffset:YES];
        if(i < 20){
            [sellData addObject:ss];
        }
    }
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    if ([dataModel.powerSeriesObject respondsToSelector:@selector(powerSeriesCallBackData:)]) {
        [dataModel.powerSeriesObject performSelector:@selector(powerSeriesCallBackData:) onThread:dataModel.thread withObject:self waitUntilDone:NO];
    }
}

@end
@implementation BuyStuff
@end
@implementation SellStuff
@end
