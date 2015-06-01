//
//  SnapShot.m
//  Bullseye
//
//  Created by Yehsam on 2008/12/12.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Snapshot.h"
#import "Commodity.h"
#import "BADataIn.h"


@implementation Snapshot

@synthesize commodityArray;
@synthesize warrantParamArray;

- (id) init
{
	if (self = [super init])
	{
		commodityArray = [[NSMutableArray alloc] init];
	}
	return self;
}

@end

@implementation IndexSnapshot

- (id) init
{
	if (self = [super init])
	{
	}
	return self;
}
@end

@implementation FutureOptionSnapshot

- (id) init
{
	if (self = [super init])
	{
	}
	return self;
}

@end


@implementation WarrantSnapshot

- (id) init
{
	if (self = [super init])
	{
	}
	return self;
}
@end


@implementation WarrantParam

@synthesize underlyingSecurity;

- (id)initWithBuff:(UInt8*)buff ObjSize:(UInt16*)size Offset:(int*)offset
{
	if (self = [super init])
	{
		underlyingSecurity = [[SymbolFormat1 alloc] initWithBuff:buff objSize:size Offset:*offset];
		buff += *size;
		TAvalueFormatData tmpTA;
		conversionRate = [CodingUtil getTAvalueFormatValue:buff Offset:offset TAstruct:&tmpTA];
		conversionRate *= pow(1000,tmpTA.magnitude);

	}
	return self;
}

@end


@implementation SnapshotParam
@synthesize snapshot;
- (id) init
{
	if (self = [super init])
	{
		snapshot = [[Snapshot alloc] init];
	}
	return self;
}

@end


@implementation EquitySnapshotDecompressed

@synthesize outerPlatUnit;
@synthesize innerPlatUnit;
@synthesize innerPlat;
@synthesize outerPlat;
@synthesize date;
@synthesize timeOfLastTick;
@synthesize statusOfEquity;	// One of the EquityPriceStatusType.
@synthesize sequenceOfTick;
@synthesize referencePrice;
@synthesize ceilingPrice;
@synthesize floorPrice;
@synthesize openPrice;
@synthesize highestPrice;
@synthesize lowestPrice;
@synthesize currentPrice;
@synthesize bid;
@synthesize ask;
@synthesize volume;
@synthesize volumeUnit;		// Unit of vlume, one of VolumeUnitType.
@synthesize accumulatedVolume;
@synthesize accumulatedVolumeUnit;	// Unit of vlume, one of VolumeUnitType.
@synthesize previousVolume;
@synthesize previousVolumeUnit;
@synthesize commodityType;
@synthesize tradeWarningCode;	//處置股票代碼: 00 ＝ 正常、01 ＝ 注意、02 ＝處置、03 ＝ 注意及處置、04 ＝ 再次處置、05 ＝ 注意及再次處置、06 ＝ 彈性處置、07 ＝ 注意及彈性處置
@synthesize delayClose;			//延後收盤 0 or 1, 0 is NO, 1 is Yes
@synthesize tradeSuspend;		//暫停交易on/off　0 or 1, 0 is 現在是沒有暫停交易, 1 is 現在是暫停交易 ..
@synthesize tradeSuspendTime;	//暫停交易時間, 絕對時間 HH:MM:SS, 999999 代表目前沒有暫停交易時間. 顯示--.	
@synthesize tradeResumeTime;	//恢復交易時間, 絕對時間 HH:MM:SS, 999999 如果有暫停交易時間, 代表時間尚未確認, 如果沒有暫停交易時間, 代表沒有恢復交易時間. 顯示--.
@synthesize dailyStatusCode;	//1st bit=1: 異常推介. 2nd bit=1: 特殊異常. 其他bit reserved 填0 (MSB)

@synthesize nearestBidAskCount;
@synthesize nearestBidPrice;
@synthesize nearestBidVolume;
@synthesize nearestBidVolumeUnit;
@synthesize nearestAskPrice;
@synthesize nearestAskVolume;
@synthesize nearestAskVolumeUnit;

@synthesize snapshotTypeGet;

@synthesize strikePrice;
//Snapshot Format 2
@synthesize week52High;
@synthesize week52Low;
//Snapshot Format 3
@synthesize eps;
@synthesize epsUnit;
@synthesize annualDividend;		//一年紅利
@synthesize annualDividendUnit;
@synthesize currentAsset;		//資產淨值
@synthesize currentAssetUnit;
@synthesize issuedShares;		//發行股數
@synthesize issuedSharesUnit;
//Snapshot Format 4
@synthesize averageVolume;		//3月均量
@synthesize averageVolumeUnit;
//Snapshot Format 5
@synthesize settlementDay;
@synthesize warrantParamArray;


- (id)initWithEquitySanpshot:(Snapshot *)Snapshot
{
	if (self = [super init])
	{
		[self setValueToAll:Snapshot];
	}
	
	return self;
}

- (void) setValueToAll:(Snapshot *)Snapshot
{
	date = Snapshot->date;
    timeOfLastTick = Snapshot->timeOfLastTick;
	statusOfEquity = Snapshot->statusOfEquity;
	sequenceOfTick = Snapshot->sequenceOfTick;
	referencePrice = [CodingUtil ConvertPrice:Snapshot->referencePrice RefPrice:0];
	ceilingPrice = [CodingUtil ConvertPrice:Snapshot->ceilingPrice RefPrice:0];
	floorPrice = [CodingUtil ConvertPrice:Snapshot->floorPrice RefPrice:0];
	if (ceilingPrice != 0)
	{
		// If there is no limit of the price, set them to zero.
		ceilingPrice += referencePrice;
		floorPrice += referencePrice;
	}
	openPrice = [CodingUtil ConvertPrice:Snapshot->openPrice RefPrice:referencePrice];
	highestPrice = [CodingUtil ConvertPrice:Snapshot->highestPrice RefPrice:referencePrice];
	lowestPrice = [CodingUtil ConvertPrice:Snapshot->lowestPrice RefPrice:referencePrice];
	currentPrice = [CodingUtil ConvertPrice:Snapshot->currentPrice RefPrice:referencePrice];
	bid = [CodingUtil ConvertPrice:Snapshot->bid RefPrice:referencePrice];
	ask = [CodingUtil ConvertPrice:Snapshot->ask RefPrice:referencePrice];
	volume = [CodingUtil ConvertTAValue:Snapshot->volume WithType:&volumeUnit];
	accumulatedVolume = [CodingUtil ConvertTAValue:Snapshot->accumulatedVolume WithType:&accumulatedVolumeUnit];
	previousVolume = [CodingUtil ConvertTAValue:Snapshot->preVolume WithType:&previousVolumeUnit];
	commodityType = Snapshot->commodityType;
	
    tradeWarningCode = Snapshot->tradeWarningCode;	//處置股票代碼: 00 ＝ 正常、01 ＝ 注意、02 ＝處置、03 ＝ 注意及處置、04 ＝ 再次處置、05 ＝ 注意及再次處置、06 ＝ 彈性處置、07 ＝ 注意及彈性處置
	delayClose = Snapshot->delayClose;			//延後收盤 0 or 1, 0 is NO, 1 is Yes
	tradeSuspend = Snapshot->tradeSuspend;		//暫停交易on/off　0 or 1, 0 is 現在是沒有暫停交易, 1 is 現在是暫停交易 ..
	tradeSuspendTime = Snapshot->tradeSuspendTime;	//暫停交易時間, 絕對時間 HH:MM:SS, 999999 代表目前沒有暫停交易時間. 顯示--.	
	tradeResumeTime = Snapshot->tradeResumeTime;	//恢復交易時間, 絕對時間 HH:MM:SS, 999999 如果有暫停交易時間, 代表時間尚未確認, 如果沒有暫停交易時間, 代表沒有恢復交易時間. 顯示--.
	dailyStatusCode = Snapshot->dailyStatusCode;	//1st bit=1: 異常推介. 2nd bit=1: 特殊異常. 其他bit reserved 填0 (MSB)
	
    
	if(Snapshot->commodityType == kCommodityTypeWarrant)
	{
		WarrantSnapshot *warrantSnapshot = [Snapshot.commodityArray objectAtIndex:0];
		strikePrice = [CodingUtil ConvertPrice:warrantSnapshot->strikePrice RefPrice:referencePrice];
	}
	
	nearestBidAskCount = 0;
	
	if(nearestBidPrice) for(int i=0 ; i<5 ; i++) nearestBidPrice[i] = 0;
	else nearestBidPrice = malloc(sizeof(double)*5);
	
	if(nearestBidVolume) for(int i=0 ; i<5 ; i++) nearestBidVolume[i] = 0;
	else nearestBidVolume = malloc(sizeof(double)*5);
	
	if(nearestBidVolumeUnit) for(int i=0 ; i<5 ; i++) nearestBidVolumeUnit[i] = 0;
	else nearestBidVolumeUnit = malloc(sizeof(UInt16)*5);
	
	if(nearestAskPrice) for(int i=0 ; i<5 ; i++) nearestAskPrice[i] = 0;
	else nearestAskPrice = malloc(sizeof(double)*5);
	
	if(nearestAskVolume) for(int i=0 ; i<5 ; i++) nearestAskVolume[i] = 0;
	else nearestAskVolume = malloc(sizeof(double)*5);
	
	if(nearestAskVolumeUnit) for(int i=0 ; i<5 ; i++) nearestAskVolumeUnit[i] = 0;
	else nearestAskVolumeUnit = malloc(sizeof(UInt16)*5);
	
	if(Snapshot->snapshotTypeGet == 0)
		snapshotTypeGet = 1<<1;
	else
		snapshotTypeGet = Snapshot->snapshotTypeGet;
}

- (void) updateWarningCode:(UInt8)warningCode
{
	tradeWarningCode = warningCode;
}

- (void) updateDailyStatus:(UInt8)dailyStatus
{
	dailyStatusCode = dailyStatus;
}

- (void)updateDelayClose:(UInt8)value {

    delayClose = value;
}

- (void) updateWithTick:(EquityTickDataRef)tick andSeqNo: (UInt16)sequenceNo
{
	EquityTickDecompressed *exTick = [(EquityTickDecompressed *)[EquityTickDecompressed alloc] initWithTick:tick RefPrice:referencePrice];

	if (sequenceNo < sequenceOfTick && sequenceNo != 0)
		return;

	if (exTick.price != 0)
	{
		if (sequenceNo == 1)
		{
			openPrice = exTick.price;
			highestPrice = openPrice;
			lowestPrice = openPrice;
		}
		else
		{
			if (exTick.price > highestPrice) 
				highestPrice = exTick.price;
			if (exTick.price < lowestPrice) 
				lowestPrice = exTick.price;
		}
		if(lowestPrice < week52Low)		//去比較52周最高最低
			week52Low = lowestPrice;
		else if(highestPrice > week52High)
			week52High = highestPrice;
		currentPrice = exTick.price;
	}
	bid = exTick.bid;
	ask = exTick.ask;
	// Update accumulated volume and volume type.
    
    volume = exTick.volume - accumulatedVolume;
//    accumulatedVolume = exTick.volume;
    
    [CodingUtil updateVolume:&accumulatedVolume Unit:&accumulatedVolumeUnit WithVolume:exTick.volume Unit:exTick.volumeUnit];
    
	if (sequenceNo != 0) 
		sequenceOfTick = sequenceNo;
}
//近五檔
- (void) updateWithNearestBidAsk:(NSMutableArray*)array
{
	nearestBidAskCount = [array count];
	if (nearestBidAskCount)
	{
		BADataParam *baParam = (BADataParam *)[array objectAtIndex:0];
		nearestBidPrice[0] = [CodingUtil ConvertPrice:baParam->bidPrice RefPrice:referencePrice];
		nearestBidVolume[0] = [CodingUtil ConvertTAValue:baParam->bidVolume WithType:&nearestBidVolumeUnit[0]];
		nearestAskPrice[0] = [CodingUtil ConvertPrice:baParam->askPrice RefPrice:referencePrice];
		nearestAskVolume[0] = [CodingUtil ConvertTAValue:baParam->askVolume WithType:&nearestAskVolumeUnit[0]];
	}
	for (int i = 1; i < nearestBidAskCount; i++)
	{
		BADataParam *baParam = (BADataParam *)[array objectAtIndex:i];
		nearestBidPrice[i] = [CodingUtil ConvertPrice:baParam->bidPrice RefPrice:nearestBidPrice[i-1]];
		nearestBidVolume[i] = [CodingUtil ConvertTAValue:baParam->bidVolume WithType:&nearestBidVolumeUnit[i]];
		nearestAskPrice[i] = [CodingUtil ConvertPrice:baParam->askPrice RefPrice:nearestAskPrice[i-1]];
		nearestAskVolume[i] = [CodingUtil ConvertTAValue:baParam->askVolume WithType:&nearestAskVolumeUnit[i]];
	}
}

- (void) updateWithClear:(MessageType06Param *)tmParam
{
	nearestBidAskCount = 0;
	date = tmParam->date;
	statusOfEquity = 0;
	sequenceOfTick = 0;
	referencePrice = [CodingUtil ConvertPrice:tmParam->referencePrice RefPrice:0];
	ceilingPrice = [CodingUtil ConvertPrice:tmParam->ceilingPrice RefPrice:0];
	floorPrice = [CodingUtil ConvertPrice:tmParam->floorPrice RefPrice:0];
	if (ceilingPrice != 0)
	{
		// If there is no limit of the price, set them to zero.
		ceilingPrice += referencePrice;
		floorPrice += referencePrice;
	}
	openPrice = 0;
	highestPrice = 0;
	lowestPrice = 0;
	currentPrice = 0;
	bid = 0;
	ask = 0;
	volume = 0;
	accumulatedVolume = 0;
	previousVolume = [CodingUtil ConvertTAValue:tmParam->preVolume WithType:&previousVolumeUnit];
}

- (void) updateWithOtherTypeSnapshot:(Snapshot*)snap
{
	if(snap->subType == 1)
	{
		[self setValueToAll:snap];
	}
	else if(snap->subType == 2)
	{
		week52High = [CodingUtil ConvertPrice:snap->week52High RefPrice:0];
		week52Low = [CodingUtil ConvertPrice:snap->week52Low RefPrice:0];
		if(highestPrice > week52High)
			week52High = highestPrice;
		if(lowestPrice < week52Low)
			week52Low = lowestPrice;
		snapshotTypeGet = snapshotTypeGet | 1<<2;
	}
	else if(snap->subType == 3)
	{
		eps = [CodingUtil ConvertTAValue:snap->eps WithType:&epsUnit];
		annualDividend = [CodingUtil ConvertTAValue:snap->annualDividend WithType:&annualDividendUnit];
		currentAsset = [CodingUtil ConvertTAValue:snap->currentAsset WithType:&currentAssetUnit];
		issuedShares = [CodingUtil ConvertTAValue:snap->issuedShares WithType:&issuedSharesUnit];
		snapshotTypeGet = snapshotTypeGet | 1<<3;
	}
	else if(snap->subType == 4)
	{
		averageVolume = [CodingUtil ConvertTAValue:snap->averageVolume WithType:&averageVolumeUnit];
		snapshotTypeGet = snapshotTypeGet | 1<<4;
	}
	else if(snap->subType == 5)
	{
		settlementDay = snap->settlementDay;
		warrantParamArray = [[NSMutableArray alloc] initWithArray:snap->warrantParamArray];
		snapshotTypeGet = snapshotTypeGet | 1<<5;
	}
}

- (void)dealloc
{
	if (nearestBidPrice) free(nearestBidPrice);
	if (nearestBidVolume) free(nearestBidVolume);
	if (nearestBidVolumeUnit) free(nearestBidVolumeUnit);
	if (nearestAskPrice) free(nearestAskPrice);
	if (nearestAskVolume) free(nearestAskVolume);
	if (nearestAskVolumeUnit) free(nearestAskVolumeUnit);
}

@end

@implementation IndexSnapshotDecompressed

@synthesize bidRecordCount;
@synthesize bidRecordCountUnit;
@synthesize askRecordCount;
@synthesize askRecordCountUnit;
@synthesize bidVolume;
@synthesize bidVolumeUnit;
@synthesize askVolume;
@synthesize askVolumeUnit;
@synthesize dealVolume;
@synthesize dealVolumeUnit;
@synthesize dealRecordCount;
@synthesize dealRecordCountUnit;
@synthesize upSecurityNo;
@synthesize downSecurityNo;
@synthesize unchangedSecurityNo;

- (id)initWithEquitySanpshot:(Snapshot *)Snapshot
{
	if (self = [super initWithEquitySanpshot:Snapshot])
	{
		IndexSnapshot *indSnapshot = [Snapshot->commodityArray objectAtIndex:0];
		
		bidRecordCount = [CodingUtil ConvertTAValue:indSnapshot->bidRecordCount WithType:&bidRecordCountUnit];
		askRecordCount = [CodingUtil ConvertTAValue:indSnapshot->askRecordCount WithType:&askRecordCountUnit];
		bidVolume = [CodingUtil ConvertTAValue:indSnapshot->bidVolume WithType:&bidVolumeUnit];
		askVolume = [CodingUtil ConvertTAValue:indSnapshot->askVolume WithType:&askVolumeUnit];
		dealVolume = [CodingUtil ConvertTAValue:indSnapshot->dealVolume WithType:&dealVolumeUnit];
		dealRecordCount = [CodingUtil ConvertTAValue:indSnapshot->dealRecordCount WithType:&dealRecordCountUnit];
		upSecurityNo = indSnapshot->upSecurityNo;
		downSecurityNo = indSnapshot->downSecurityNo;
		unchangedSecurityNo = indSnapshot->unchangedSecurityNo;
	}
	
	return self;
}

- (void) setValueToAll:(Snapshot *)Snapshot
{
	[super setValueToAll:Snapshot];
	IndexSnapshot *indSnapshot = [Snapshot->commodityArray objectAtIndex:0];
	
	bidRecordCount = [CodingUtil ConvertTAValue:indSnapshot->bidRecordCount WithType:&bidRecordCountUnit];
	askRecordCount = [CodingUtil ConvertTAValue:indSnapshot->askRecordCount WithType:&askRecordCountUnit];
	bidVolume = [CodingUtil ConvertTAValue:indSnapshot->bidVolume WithType:&bidVolumeUnit];
	askVolume = [CodingUtil ConvertTAValue:indSnapshot->askVolume WithType:&askVolumeUnit];
	dealVolume = [CodingUtil ConvertTAValue:indSnapshot->dealVolume WithType:&dealVolumeUnit];
	dealRecordCount = [CodingUtil ConvertTAValue:indSnapshot->dealRecordCount WithType:&dealRecordCountUnit];
	upSecurityNo = indSnapshot->upSecurityNo;
	downSecurityNo = indSnapshot->downSecurityNo;
	unchangedSecurityNo = indSnapshot->unchangedSecurityNo;
}

- (void) updateWithTick:(IndexTickDataRef)tick andSeqNo: (UInt16)sequenceNo
{
	IndexTickDecompressed *indTick = [(IndexTickDecompressed *)[IndexTickDecompressed alloc] initWithTick:tick RefPrice:referencePrice];
	
	if (sequenceNo < sequenceOfTick && sequenceNo != 0)
		return;

	if (indTick.price != 0)
	{
		if (sequenceNo == 1)
		{
			openPrice = indTick.price;
			highestPrice = openPrice;
			lowestPrice = openPrice;
		}
		else
		{
			if (indTick.price > highestPrice) 
				highestPrice = indTick.price;
			if (indTick.price < lowestPrice) 
				lowestPrice = indTick.price;
		}
		if(lowestPrice < week52Low)		//去比較52周最高最低
			week52Low = lowestPrice;
		else if(highestPrice > week52High)
			week52High = highestPrice;
		currentPrice = indTick.price;
	}
	
	// Update the accumulated volume.
	[CodingUtil updateVolume:&accumulatedVolume Unit:&accumulatedVolumeUnit WithVolume:indTick.volume Unit:indTick.volumeUnit];
	
	dealVolume = indTick.dealvolume;
	dealVolumeUnit = indTick.dealvolumeUnit;
	dealRecordCount = indTick.dealCount;
	dealRecordCountUnit = indTick.dealCountUnit;
	bidVolume = indTick.bidVolume;
	bidVolumeUnit = indTick.bidVolumeUnit;
	bidRecordCount = indTick.bidCount;
	bidRecordCountUnit = indTick.bidCountUnit;
	askVolume = indTick.askVolume;
	askVolumeUnit = indTick.askVolumeUnit;
	askRecordCount = indTick.askCount;
	askRecordCountUnit = indTick.askCountUnit;
	upSecurityNo = indTick.upNo;
	downSecurityNo = indTick.downNo;
	unchangedSecurityNo = indTick.unchangedNo;
	if (sequenceNo != 0) 
		sequenceOfTick = sequenceNo;
}

- (void) updateWithOtherTypeSnapshot:(Snapshot*)snap
{
	if(snap->subType == 1)
	{
		[self setValueToAll:snap];
	}
	else
		[super updateWithOtherTypeSnapshot:snap];
}	

@end

