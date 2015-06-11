//
//  StockHolderMeetingIn.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "StockHolderMeetingIn.h"

@implementation StockHolderMeetingIn
- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	dataType = [CodingUtil getUInt8:&body needOffset:YES];
    if(dataType == 1){
        stockHolderObject = [[StockHolderMeetingData alloc] init];
        stockHolderObject->DataDate = [CodingUtil getUInt16:&body needOffset:YES];
        if(!stockHolderObject->DataDate ==0){
            stockHolderObject->meetingDate = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->lastTranDate = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopTranDate = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopShrDateBegin = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopShrDateEnd = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->retShrDate = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopAmntDateBegin = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopAmntDateEnd = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->ernDiv = [[FSBValueFormat alloc]initWithByte:&body needOffset:YES];
            stockHolderObject->capDiv = [[FSBValueFormat alloc]initWithByte:&body needOffset:YES];
            stockHolderObject->cashDiv = [[FSBValueFormat alloc]initWithByte:&body needOffset:YES];
            stockHolderObject->boardReElection = [CodingUtil getShortStringFormatByBuffer:&body needOffset:YES];
        }
    }else if(dataType == 2){
        stockHolderObject = [[StockHolderMeetingData alloc] init];
        stockHolderObject->DataDate = [CodingUtil getUInt16:&body needOffset:YES];
        if(!stockHolderObject->DataDate ==0){
            stockHolderObject->meetingDate = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->lastTranDate = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopTranDate = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopShrDateBegin = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopShrDateEnd = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->retShrDate = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopAmntDateBegin = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopAmntDateEnd = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stockDividendReleaseDate = [CodingUtil getUInt16:&body needOffset:YES];
        }
    }else if(dataType == 3){
        stockHolderObject = [[StockHolderMeetingData alloc] init];
        stockHolderObject->DataDate = [CodingUtil getUInt16:&body needOffset:YES];
        if(!stockHolderObject->DataDate ==0){

            stockHolderObject->meetingDate = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->lastTranDate = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopTranDate = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopShrDateBegin = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopShrDateEnd = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->retShrDate = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopAmntDateBegin = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopAmntDateEnd = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->cashDividendReleaseDate = [CodingUtil getUInt16:&body needOffset:YES];
        }
    }else if(dataType == 4){
        stockHolderObject = [[StockHolderMeetingData alloc] init];
        stockHolderObject->DataDate = [CodingUtil getUInt16:&body needOffset:YES];
        if(!stockHolderObject->DataDate ==0){
            stockHolderObject->meetingDate = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->lastTranDate = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopTranDate = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopShrDateBegin = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopShrDateEnd = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->retShrDate = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopAmntDateBegin = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->stopAmntDateEnd = [CodingUtil getUInt16:&body needOffset:YES];
            stockHolderObject->capIncAmnt = [[FSBValueFormat alloc]initWithByte:&body needOffset:YES];
            stockHolderObject->capIncStkPrice = [[FSBValueFormat alloc]initWithByte:&body needOffset:YES];
            stockHolderObject->capIncStockRatio = [[FSBValueFormat alloc]initWithByte:&body needOffset:YES];
            stockHolderObject->newCapital = [[FSBValueFormat alloc]initWithByte:&body needOffset:YES];
            stockHolderObject->cashAndStockReleaseDate = [CodingUtil getUInt16:&body needOffset:YES];
        }
    }else if(dataType == 5){
        stockHolderObject = [[StockHolderMeetingData alloc] init];
        stockHolderObject->taxDate = [CodingUtil getUInt16:&body needOffset:YES];
        stockHolderObject->taxCredit = [[FSBValueFormat alloc]initWithByte:&body needOffset:YES];
    }
     
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    if ([model.stockHolderMeeting respondsToSelector:@selector(stockHolderMeetingDataCallBack:)]) {
        
        [model.stockHolderMeeting performSelector:@selector(stockHolderMeetingDataCallBack:) onThread:model.thread withObject:self waitUntilDone:NO];
    }
    
}
@end

@implementation StockHolderMeetingData
@end
