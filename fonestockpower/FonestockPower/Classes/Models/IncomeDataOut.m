//
//  IncomeDataOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "IncomeDataOut.h"
#import "OutPacket.h"

@implementation IncomeDataOut

- (id)initWithSpecifyDate:(UInt16)sDate CommodityNum:(UInt32)cn DataType:(char)dt
{
	if( self = [super init])
	{
		commodityNum = cn;
		dataType = dt;
		queryType = 0;
		date = sDate;
	}
	return self;
}
- (id)initWithStartDate:(UInt16)sDate EndDate:(UInt16)eDate CommodityNum:(UInt32)cn DataType:(char)dt
{
	if( self = [super init])
	{
		commodityNum = cn;
		dataType = dt;
		queryType = 1;
		date = sDate;
		endDate = eDate;
	}
	return self;
}

- (int)getPacketSize
{
	if(queryType){
        if(dataType == 'X' || dataType == 'Y'){
            return 14;
        }else{
            return 10;//多一個endDate
        }

    }
	else return 8;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 2;
	phead->command = 3;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
	
	[CodingUtil setUInt32:tmpPtr Value:commodityNum];
	tmpPtr += 4;
	*tmpPtr++ = dataType;
	*tmpPtr++ = queryType;
	[CodingUtil setUInt16:tmpPtr Value:date];
	tmpPtr += 2;
	if(queryType){
        [CodingUtil setUInt16:tmpPtr Value:endDate];
        tmpPtr += 2;
    }
	if(dataType == 'X' || dataType == 'Y'){
        [CodingUtil setUInt16:tmpPtr Value:date];
        tmpPtr += 2;
        [CodingUtil setUInt16:tmpPtr Value:endDate];
        tmpPtr += 2;
    }
    
	return YES;
}

@end
