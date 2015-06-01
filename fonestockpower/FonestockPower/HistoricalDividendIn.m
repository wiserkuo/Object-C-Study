//
//  HistoricalDividendIn.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "HistoricalDividendIn.h"
#import "OutPacket.h"
@implementation HistoricalDividendIn
- (id)init
{
	if(self = [super init])
	{
		historicalDividendArray = [[NSMutableArray alloc] init];
	}
	return self;
}


- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
    UInt8 *tmpPtr=body;
    int offset = 0;
	int count = [CodingUtil getUint8FromBuf:tmpPtr Offset:offset Bits:8];
    offset +=8;
    NSUInteger componentFlags = NSYearCalendarUnit;
    NSInteger year;
	for(int i=0 ; i<count ; i++)
	{
		HistoricalDividendParam *historicalDividendParam = [[HistoricalDividendParam alloc] init];
		historicalDividendParam->date = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:16];
        offset +=16;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:componentFlags fromDate:[[NSNumber numberWithInt:historicalDividendParam->date]uint16ToDate]];
        if(i == 0){
            year = [components year];
        }
        NSInteger detailYear = [components year];
        TAvalueFormatData tmpTA;
        if(year == detailYear){
            historicalDividendParam->emDiv = [self determinedDecimal:[CodingUtil getTAvalue:tmpPtr Offset:&offset TAstruct:&tmpTA]];
//            historicalDividendParam->emDiv = [NSString stringWithFormat:@"%.3f", [CodingUtil getTAvalue:tmpPtr Offset:&offset TAstruct:&tmpTA]];
            historicalDividendParam->emDivUnit = tmpTA.magnitude;
            historicalDividendParam->capDiv = [self determinedDecimal:[CodingUtil getTAvalue:tmpPtr Offset:&offset TAstruct:&tmpTA]];
//            historicalDividendParam->capDiv = [NSString stringWithFormat:@"%.3f",[CodingUtil getTAvalue:tmpPtr Offset:&offset TAstruct:&tmpTA]];
            historicalDividendParam->capDivUnit = tmpTA.magnitude;
            historicalDividendParam->cshDiv = [self determinedDecimal:[CodingUtil getTAvalue:tmpPtr Offset:&offset TAstruct:&tmpTA]];
//            historicalDividendParam->cshDiv = [NSString stringWithFormat:@"%.3f",[CodingUtil getTAvalue:tmpPtr Offset:&offset TAstruct:&tmpTA]];
            historicalDividendParam->cshDivUnit = tmpTA.magnitude;
        }else{
            for(int y = 0 ; year != detailYear || y == 5 ; y++){
                HistoricalDividendParam *noData = [[HistoricalDividendParam alloc] init];
                UInt16 date = [CodingUtil makeDate:year month:1 day:1];
                noData->date = date;
                noData->emDiv = @"----";
                noData->capDiv = @"----";
                noData->cshDiv = @"----";
                [historicalDividendArray addObject:noData];
                year --;
            }
            if(year == detailYear){
//                historicalDividendParam->emDiv = [NSString stringWithFormat:@"%.3f", [CodingUtil getTAvalue:tmpPtr Offset:&offset TAstruct:&tmpTA]];
                historicalDividendParam->emDiv = [self determinedDecimal:[CodingUtil getTAvalue:tmpPtr Offset:&offset TAstruct:&tmpTA]];
                historicalDividendParam->emDivUnit = tmpTA.magnitude;
                historicalDividendParam->capDiv = [self determinedDecimal:[CodingUtil getTAvalue:tmpPtr Offset:&offset TAstruct:&tmpTA]];
//                historicalDividendParam->capDiv = [NSString stringWithFormat:@"%.3f",[CodingUtil getTAvalue:tmpPtr Offset:&offset TAstruct:&tmpTA]];
                historicalDividendParam->capDivUnit = tmpTA.magnitude;
                historicalDividendParam->cshDiv = [self determinedDecimal:[CodingUtil getTAvalue:tmpPtr Offset:&offset TAstruct:&tmpTA]];
//                historicalDividendParam->cshDiv = [NSString stringWithFormat:@"%.3f",[CodingUtil getTAvalue:tmpPtr Offset:&offset TAstruct:&tmpTA]];
                historicalDividendParam->cshDivUnit = tmpTA.magnitude;
            }
        }
		[historicalDividendArray addObject:historicalDividendParam];
        if([historicalDividendArray count]==6){
            break;
        }
        year --;
	}
    
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    if ([model.stockHolderMeeting respondsToSelector:@selector(HistoricalDividendDataCallBack:)]) {
        
        [model.stockHolderMeeting performSelector:@selector(HistoricalDividendDataCallBack:) onThread:model.thread withObject:self waitUntilDone:NO];
    }
    
}

-(NSString *)determinedDecimal:(double)TAvalue{
    NSString *text = nil;
    if (TAvalue > 100) {
        text = [NSString stringWithFormat:@"%.1f", TAvalue];
    }else if (TAvalue > 10){
        text = [NSString stringWithFormat:@"%.2f", TAvalue];
    }else{
        text = [NSString stringWithFormat:@"%.3f", TAvalue];
    }
    return text;
}
@end
@implementation HistoricalDividendParam
@end
