//
//  Tick.h
//  FonestockPower
//
//  Created by Neil on 14/4/29.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct
{
	UInt16 time;
	UInt32 price;
	UInt32 volume;
    UInt8 volumeType;
    double volumeDouble;
	UInt16 volumeUnit;
} TickData, *TickDataRef;

typedef struct tickdata
{
	TickData tick;
	UInt8 status;
	UInt32 bid;
	UInt32 ask;
}EquityTickData,*EquityTickDataRef;

typedef struct
{
	TickData tick;
	UInt32 dealvolume;
	UInt32 dealCount;
	UInt32 dealValue;
	UInt32 bidVolume;
	UInt32 bidCount;
	UInt32 askVolume;
	UInt32 askCount;
	UInt16 upNo;
	UInt16 downNo;
	UInt16 unchangedNo;
} IndexTickData, *IndexTickDataRef;

#if 0
@interface TickParam : NSObject{
@public
	UInt32 securityNO;
	UInt16 sequence;
	UInt8 volumeType;
	union
	{
		EquityTickData etick;
		IndexTickData itick;
	} tickData;
}
@end
#else
@interface EquityTickParam : NSObject{
@public
	UInt32 securityNO;
	UInt16 sequence;
	UInt8 volumeType;
	EquityTickData etick;
}
@end
@interface IndexTickParam : NSObject{
@public
	UInt32 securityNO;
	UInt16 sequence;
	UInt8 volumeType;
	IndexTickData itick;
}
@end
#endif

@interface TickDecompressed : NSObject
{
	UInt16 time;		// Minutes from the market start time.
	double price;
    UInt8 volumeType;
	double volume;
	UInt16 volumeUnit;	// Unit of the volume, should be one fo the VolumeUnitType.
    
}

@property (nonatomic, readonly) UInt16 time;
@property (nonatomic, readonly) double price;
@property (nonatomic, readonly) double volume;
@property (nonatomic, readonly) UInt16 volumeUnit;
@property (nonatomic) UInt8 volumeType;

- (id)initWithTick:(TickDataRef)tick RefPrice:(double)refVal;

@end


@interface EquityTickDecompressed : TickDecompressed
{
	double bid;
	double ask;
}

@property (nonatomic, readonly) double bid;
@property (nonatomic, readonly) double ask;

- (id) initWithTick:(EquityTickDataRef)tick RefPrice:(double)refVal;

@end

@interface IndexTickDecompressed : TickDecompressed
{
	double dealvolume;
	UInt16 dealvolumeUnit;
	double dealCount;
	UInt16 dealCountUnit;
	double dealValue;
	UInt16 dealValueUnit;
	double bidVolume;
	UInt16 bidVolumeUnit;
	double bidCount;
	UInt16 bidCountUnit;
	double askVolume;
	UInt16 askVolumeUnit;
	double askCount;
	UInt16 askCountUnit;
	UInt16 upNo;
	UInt16 downNo;
	UInt16 unchangedNo;
}

@property (nonatomic, readonly) double dealvolume;
@property (nonatomic, readonly) UInt16 dealvolumeUnit;
@property (nonatomic, readonly) double dealCount;
@property (nonatomic, readonly) UInt16 dealCountUnit;
@property (nonatomic, readonly) double dealValue;
@property (nonatomic, readonly) UInt16 dealValueUnit;
@property (nonatomic, readonly) double bidVolume;
@property (nonatomic, readonly) UInt16 bidVolumeUnit;
@property (nonatomic, readonly) double bidCount;
@property (nonatomic, readonly) UInt16 bidCountUnit;
@property (nonatomic, readonly) double askVolume;
@property (nonatomic, readonly) UInt16 askVolumeUnit;
@property (nonatomic, readonly) double askCount;
@property (nonatomic, readonly) UInt16 askCountUnit;
@property (nonatomic, readonly) UInt16 upNo;
@property (nonatomic, readonly) UInt16 downNo;
@property (nonatomic, readonly) UInt16 unchangedNo;

- (id) initWithTick:(IndexTickDataRef)tick RefPrice:(double)refVal;

@end

