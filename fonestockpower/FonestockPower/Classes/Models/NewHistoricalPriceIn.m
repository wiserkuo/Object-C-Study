//
//  NewHistoricalPriceIn.m
//  Bullseye
//
//  Created by Connor on 13/9/6.
//
//

#import "NewHistoricalPriceIn.h"
#import "HistoricalParm.h"

@implementation NewHistoricalPriceIn
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
	historicalParm->commodityNum = commodity;
	historicalParm->type = *tmpPtr++;
    
    historicalParm->dataCount = [CodingUtil getUInt16:tmpPtr];
    tmpPtr += 2;
    
    if (historicalParm->dataCount == 0) {
//        NSLog(@"NO Data");
    } else {
//        NSLog(@"Data In");        
    }
    
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	PortfolioItem *portfolioItem;
	portfolioItem = [dataModal.portfolioData getAllItem:commodity];
	if( (historicalParm->type =='D') || (historicalParm->type=='W') || (historicalParm->type=='M'))  //use historical price format 1
	{
		int offset=0;
		int tmpOffset;
		for(int i=0 ; i<historicalParm->dataCount ; i++)
		{
            
			HistoricalDataFormat1 *hisData1 = [[HistoricalDataFormat1 alloc] init];
			hisData1->date = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:16];
            
			offset+=16;
            
			tmpOffset = offset;
			tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
            [CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&hisData1->openPrice Offset:0];
			tmpOffset = offset;
			
			tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
            [CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&hisData1->highPrice Offset:0];
			tmpOffset = offset;
			
			tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
            [CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&hisData1->lowPrice Offset:0];
			tmpOffset = offset;
			
			tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
            [CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&hisData1->closePrice Offset:0];
			tmpOffset = offset;
			
			double volume = [CodingUtil getTAvalue:tmpPtr Offset:&offset TAstruct:&tmpTA];
            
            [CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&hisData1->volume Offset:0];
			tmpOffset = offset;
#ifdef SERVER_SYNC
			if  (portfolioItem !=nil){

                if(portfolioItem->type_id == 4)   //type_id == 4 是期貨
                {
                    tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
                    tmpOffset = offset;
                }
            }
#endif
            
            [historicalParm.historicalDataArray addObject:hisData1];
//            NSLog(@"%@", [[NSNumber numberWithInt:hisData1->date] uint16ToDate]);

            [dataModal.todayReserve performSelector:@selector(setHistoricTickVolume:) onThread:dataModal.thread withObject: [NSNumber numberWithDouble:volume] waitUntilDone:NO];
            
		}
	}
	else
	{
		int offset=0;
		int tmpOffset;
		for(int i=0 ; i<historicalParm->dataCount ; i++)
		{
			HistoricalDataFormat2 *hisData2 = [[HistoricalDataFormat2 alloc] init];
			if([CodingUtil getUint8FromBuf:tmpPtr Offset:offset++ Bits:1])
			{
				hisData2->dateFlag = YES;
				hisData2->date = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:16];
				offset+=16;
			}
			else hisData2->dateFlag = NO;
			hisData2->time = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:12];
			offset+=12;
			tmpOffset = offset;
			tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
			[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&hisData2->openPrice Offset:0];
			tmpOffset = offset;
			
			tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
			[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&hisData2->highPrice Offset:0];
			tmpOffset = offset;
			
			tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
			[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&hisData2->lowPrice Offset:0];
			tmpOffset = offset;
			
			tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
			[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&hisData2->closePrice Offset:0];
			tmpOffset = offset;
            
			tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
			[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&hisData2->volume Offset:0];
			tmpOffset = offset;
			[historicalParm.historicalDataArray addObject:hisData2];
		}
	}
	[dataModal.historicTickBank performSelector:@selector(addHistoricTick:) onThread:dataModal.thread withObject:historicalParm waitUntilDone:NO];
}

@end
