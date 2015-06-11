//
//  StockHolderMeetingIn.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
@class StockHolderMeetingData;
@interface StockHolderMeetingIn : NSObject <DecodeProtocol>{
    
@public
    UInt8 dataType;
    StockHolderMeetingData *stockHolderObject;
}

@end

@interface StockHolderMeetingData : NSObject
{
@public
    UInt16 DataDate;
    UInt16 meetingDate;
    UInt16 lastTranDate;
    UInt16 stopTranDate;
    UInt16 stopShrDateBegin;
    UInt16 stopShrDateEnd;
    UInt16 retShrDate;
    UInt16 stopAmntDateBegin;
    UInt16 stopAmntDateEnd;
    //Type1
    FSBValueFormat *ernDiv;
    FSBValueFormat *capDiv;
    FSBValueFormat *cashDiv;
    NSString *boardReElection;
    //Type2
    UInt16 stockDividendReleaseDate;
    //Type3
    UInt16 cashDividendReleaseDate;
    //Type4
    FSBValueFormat *capIncAmnt;
    FSBValueFormat *capIncStkPrice;
    FSBValueFormat *capIncStockRatio;
    FSBValueFormat *newCapital;
    UInt16 cashAndStockReleaseDate;
    //Type5
    UInt16 taxDate;
    FSBValueFormat *taxCredit;
}
@end