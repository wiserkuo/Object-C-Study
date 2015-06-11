//
//  HistoricDataTypes.h
//  Bullseye
//
//  Created by johaiyu on 2008/12/19.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

// Maximum value for historic date.
extern const NSUInteger MaximumHistoricDays;		// This value exceeds the maximum capacity of the server. Should cut to 255 while requesting to the server.
extern const NSUInteger MaximumHistoricWeeks;
extern const NSUInteger MaximumHistoricMonths;
extern const NSUInteger MaximumHistoric5Minutes;		// Days.

typedef enum
{
	kTickType5Minute = '5',
	kTickTypeDay = 'D',
	kTickTypeWeek = 'W',
	kTickTypeMonth = 'M',
	kTickType15Minute = 'F',
	kTickType30Minute = 'T',
	kTickType60Minute = 'S',
} TickCharType;

typedef enum 
{
	kEquityTypeStock = 1,
	kEquityTypeWarrant,
	kEquityTypeIndex,
	kEquityTypeFuture,
	kEquityTypeOption,
	kEquityTypeMarketIndex,
	kEquityTypeETF,
	kEquityTypeNews,
	kEquityTypeOther,
	kEquityTypeCurrency,
	kEquityTypeFutureOptionTarget,
	kEquityTypeConsoltancy
} EquityType;


#import <Foundation/Foundation.h>

typedef struct 
{
	UInt16 date;	// years from 1960
	UInt32 open;	// absolute value
	UInt32 high;	// relative value
	UInt32 low;		// relative value
	UInt32 close;	// relative value
	UInt32 volume;
} HistoricData, *HistoricDataRef;

typedef struct
{
	HistoricData hisData;
	UInt32 openInterest;	// volume
} HistoricFuture, *HistoricFutureRef;

typedef struct
{
	HistoricData hisData;
	UInt32 time;	// minutes from 00:00
} Historic5Minute, *Historic5MinuteRef;

@interface DecompressedHistoricData : NSObject
{
	UInt16 date;	// years from 1960
	double open;	// absolute value
	double high;	// relative value
	double low;		// relative value
	double close;	// relative value
	double volume;
	UInt16 volumeUnit;
}

@property (nonatomic/*, readonly*/) UInt16 date;	// years from 1960
@property (nonatomic/*, readonly*/) double open;	// absolute value
@property (nonatomic/*, readonly*/) double high;	// relative value
@property (nonatomic/*, readonly*/) double low;		// relative value
@property (nonatomic/*, readonly*/) double close;	// relative value
@property (nonatomic/*, readonly*/) double volume;
@property (nonatomic/*, readonly*/) UInt16 volumeUnit;

- (id)initWithData:(HistoricDataRef)data;

@end

@interface DecompressedHistoricFuture : DecompressedHistoricData
{
	double openInterest;
	UInt16 openInterestUnit;
}

@property (nonatomic/*, readonly*/) double openInterest;
@property (nonatomic/*, readonly*/) UInt16 openInterestUnit;
                    
- (id)initWithData:(HistoricFutureRef)data;

@end

@interface DecompressedHistoric5Minute : DecompressedHistoricData
{
	UInt16 time;
}

@property(nonatomic/*, readonly*/) UInt16 time;

- (id)initWithData:(Historic5MinuteRef)data;

@end
