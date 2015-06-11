//
//  Tick.m
//  FonestockPower
//
//  Created by Neil on 14/4/29.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "Tick.h"

#if 0
@implementation TickParam
@end
#else
@implementation EquityTickParam
@end
@implementation IndexTickParam
@end
#endif

@implementation TickDecompressed

@synthesize time;
@synthesize price;
@synthesize volume;
@synthesize volumeType;
@synthesize volumeUnit;

- (id)initWithTick:(TickDataRef)tick RefPrice:(double)refPrice
{
	if (self = [super init])
	{
		time = tick->time;
		price = [CodingUtil ConvertPrice:tick->price RefPrice:refPrice];
		volume = tick->volumeDouble;
        volumeUnit = tick->volumeUnit;
	}
	
	return self;
}

@end


@implementation EquityTickDecompressed

@synthesize bid;
@synthesize ask;

- (id) initWithTick:(EquityTickDataRef)tick RefPrice:(double)refPrice
{
	if (self = [super initWithTick:&(tick->tick) RefPrice:refPrice])
	{
		bid = [CodingUtil ConvertPrice:tick->bid RefPrice:price];
		ask = [CodingUtil ConvertPrice:tick->ask RefPrice:price];
	}
	return self;
}

@end

@implementation IndexTickDecompressed

@synthesize dealvolume;
@synthesize dealvolumeUnit;
@synthesize dealCount;
@synthesize dealCountUnit;
@synthesize dealValue;
@synthesize dealValueUnit;
@synthesize bidVolume;
@synthesize bidVolumeUnit;
@synthesize bidCount;
@synthesize bidCountUnit;
@synthesize askVolume;
@synthesize askVolumeUnit;
@synthesize askCount;
@synthesize askCountUnit;
@synthesize upNo;
@synthesize downNo;
@synthesize unchangedNo;

- (id) initWithTick:(IndexTickDataRef)tick RefPrice:(double)refPrice
{
	if (self = [super initWithTick:&(tick->tick) RefPrice:refPrice])
	{
		dealvolume = [CodingUtil ConvertTAValue:tick->dealvolume WithType:&dealvolumeUnit];
		dealCount = [CodingUtil ConvertTAValue:tick->dealCount WithType:&dealCountUnit];
		dealValue = [CodingUtil ConvertTAValue:tick->dealValue WithType:&dealValueUnit];
		bidVolume = [CodingUtil ConvertTAValue:tick->bidVolume WithType:&bidVolumeUnit];
		bidCount = [CodingUtil ConvertTAValue:tick->bidCount WithType:&bidCountUnit];
		askVolume = [CodingUtil ConvertTAValue:tick->askVolume WithType:&askVolumeUnit];
		askCount = [CodingUtil ConvertTAValue:tick->askCount WithType:&askCountUnit];
		upNo = tick->upNo;
		downNo = tick->downNo;
		unchangedNo = tick->unchangedNo;
	}
	
	return self;
}


@end
