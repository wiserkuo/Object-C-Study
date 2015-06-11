//
//  HistoricDataTypes.m
//  Bullseye
//
//  Created by johaiyu on 2008/12/19.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HistoricDataTypes.h"

// Maximum value for historic date.
const NSUInteger MaximumHistoricDays = 780;		// This value exceeds the maximum capacity of the server. Should cut to 255 while requesting to the server.
const NSUInteger MaximumHistoricWeeks = 520;
const NSUInteger MaximumHistoricMonths = 180;
const NSUInteger MaximumHistoric5Minutes = 30;		// Days.


@implementation DecompressedHistoricData

@synthesize date;	// years from 1960
@synthesize open;	// absolute value
@synthesize high;	// relative value
@synthesize low;		// relative value
@synthesize close;	// relative value
@synthesize volume;
@synthesize volumeUnit;

- (id)initWithData:(HistoricDataRef)data
{
	if (self = [super init])
	{
		date = data->date;
		open = [CodingUtil ConvertPrice:data->open RefPrice:0];
		high = [CodingUtil ConvertPrice:data->high RefPrice:open];
		low = [CodingUtil ConvertPrice:data->low RefPrice:open];
		close = [CodingUtil ConvertPrice:data->close RefPrice:open];
		volume = [CodingUtil ConvertTAValue:data->volume WithType:&volumeUnit];
	}
	
	return self;
}

- (BOOL)isEqual:(DecompressedHistoricData *)obj
{
    return date == obj.date && open == obj.open && high == obj.high && low == obj.low && close == obj.close &&
           volume == obj.volume && volumeUnit == obj.volumeUnit;
}

@end

@implementation DecompressedHistoricFuture

@synthesize openInterest;
@synthesize openInterestUnit;

- (id)initWithData:(HistoricFutureRef)data
{
	if (self = [super initWithData:&(data->hisData)])
	{
		openInterest = [CodingUtil ConvertTAValue:data->openInterest WithType:&openInterestUnit];
	}
	
	return self;
}

- (BOOL)isEqual:(DecompressedHistoricFuture *)obj
{
    return [super isEqual:obj] && openInterest == obj.openInterest && openInterestUnit == obj.openInterestUnit;
}

@end

@implementation DecompressedHistoric5Minute

@synthesize time;

- (id)initWithData:(Historic5MinuteRef)data
{
	if (self = [super initWithData:&(data->hisData)])
	{
		time = data->time;
	}
	
	return self;
}

- (BOOL)isEqual:(DecompressedHistoric5Minute *)obj
{
    return [super isEqual:obj] && time == obj.time;
}

@end
