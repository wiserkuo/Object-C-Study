//
//  TechIn.m
//  FonestockPower
//
//  Created by Kenny on 2014/12/8.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "TechIn.h"
#import "HistoricalParm.h"

@implementation TechIn
@synthesize historicalParm;
- (id)init {
    if(self = [super init]) {
        historicalParm = [[HistoricalParm alloc] init];
    }
    return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode {
    UInt8 *tmpPtr = body;
    PriceFormatData tmpPrice;
    TAvalueFormatData tmpTA;
    double tmpVal;
    historicalParm->retcode = retcode;
    _retCode = retcode;
    historicalParm->commodityNum = commodity;
//    NSString *identCodeSymbol = [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
    [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
    historicalParm->type = *tmpPtr++;
    
    historicalParm->dataCount = [CodingUtil getUInt16:tmpPtr];
    tmpPtr += 2;
    
    if (historicalParm->dataCount == 0) {
        NSLog(@"NO Data");
    } else {
        NSLog(@"Data In");
    }
    
    self.dataArray = [[NSMutableArray alloc] init];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    PortfolioItem *portfolioItem;
    portfolioItem = [dataModel.portfolioData getAllItem:commodity];
    if( (historicalParm->type =='D') || (historicalParm->type=='W') || (historicalParm->type=='M'))  //use historical price format 1
    {
        int offset=0;
        int tmpOffset;
        for(int i=0 ; i<historicalParm->dataCount ; i++)
        {
            TechObject *techObj = [[TechObject alloc] init];
            
            HistoricalDataFormat1 *hisData1 = [[HistoricalDataFormat1 alloc] init];
            techObj.date = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:16];
            offset+=16;
            tmpOffset = offset;
            tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
            [CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&hisData1->openPrice Offset:0];
            tmpOffset = offset;
            
            techObj.open = [CodingUtil ConvertPrice:hisData1->openPrice RefPrice:0];
            tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
            [CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&hisData1->highPrice Offset:0];
            tmpOffset = offset;
            
            techObj.high = [CodingUtil ConvertPrice:hisData1->highPrice RefPrice:techObj.open];
            
            tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
            [CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&hisData1->lowPrice Offset:0];
            tmpOffset = offset;
            
            techObj.low = [CodingUtil ConvertPrice:hisData1->lowPrice RefPrice:techObj.open];
            
            tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
            [CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&hisData1->closePrice Offset:0];
            tmpOffset = offset;
            
            techObj.last = [CodingUtil ConvertPrice:hisData1->closePrice RefPrice:techObj.open];
            
            double volume = [CodingUtil getTAvalue:tmpPtr Offset:&offset TAstruct:&tmpTA];
            [CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&hisData1->volume Offset:0];
            
            techObj.volume = volume;
            
//            UInt16 a;
//            UInt8 b, c;
//            
//            [CodingUtil getDate:techObj.date year:&a month:&b day:&c];
//            NSLog(@"%d/%d/%d --> %f", a, b, c, techObj.volume);
            
            tmpOffset = offset;

            if  (portfolioItem !=nil){
#ifdef SERVER_SYNC
                if(portfolioItem->type_id == 4)   //type_id == 4 是期貨
                {
                    tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
                    tmpOffset = offset;
                }
#endif
            }
            
            [_dataArray addObject:techObj];

        }

    }


    [dataModel.tech performSelector:@selector(techCallBackData:) onThread:dataModel.thread withObject:self waitUntilDone:NO];
}
@end

@implementation TechObject
@end