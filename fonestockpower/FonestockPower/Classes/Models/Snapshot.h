//
//  Snapshot.h
//  Bullseye
//
//  Created by Yehsam on 2008/12/12.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tick.h"
#import "MessageType06.h"


@class WarrantParam;
@interface Snapshot : NSObject {
@public
	UInt8 subType;		//type of snapshot
	UInt16 date;
	UInt16 timeOfLastTick;
	UInt8 statusOfEquity;
	UInt16 sequenceOfTick;
	UInt32 referencePrice;
	UInt32 ceilingPrice;
	UInt32 floorPrice;
	UInt32 openPrice;
	UInt32 highestPrice;
	UInt32 lowestPrice;
	UInt32 currentPrice;
	UInt32 bid;
	UInt32 ask;
	UInt32 volume;
	UInt32 accumulatedVolume;
	UInt32 preVolume;
	UInt8 commodityType;
    UInt8 tradeWarningCode;				//處置股票代碼: 00 ＝ 正常、01 ＝ 注意、02 ＝處置、03 ＝ 注意及處置、04 ＝ 再次處置、05 ＝ 注意及再次處置、06 ＝ 彈性處置、07 ＝ 注意及彈性處置
	UInt8 delayClose;					//延後收盤 0 or 1, 0 is NO, 1 is Yes
	UInt8 tradeSuspend;					//暫停交易on/off　0 or 1, 0 is 現在是沒有暫停交易, 1 is 現在是暫停交易 ..
	UInt32 tradeSuspendTime;			//暫停交易時間, 絕對時間 HH:MM:SS, 999999 代表目前沒有暫停交易時間. 顯示--.	
	UInt32 tradeResumeTime;				//恢復交易時間, 絕對時間 HH:MM:SS, 999999 如果有暫停交易時間, 代表時間尚未確認, 如果沒有暫停交易時間, 代表沒有恢復交易時間. 顯示--.
	UInt8 dailyStatusCode;				//1st bit=1: 異常推介. 2nd bit=1: 特殊異常. 其他bit reserved 填0 (MSB)
	
	NSMutableArray *commodityArray;			
	//Snapshot Format 2
	UInt32 week52High;
	UInt32 week52Low;
	//Snapshot Format 3
	UInt32 eps;
	UInt32 annualDividend;		//一年紅利
	UInt32 currentAsset;		//資產淨值
	UInt32 issuedShares;		//發行股數
	//Snapshot Format 4
	UInt32 averageVolume;		//3月均量
	//Snapshot Format 5
	UInt16 settlementDay;
    //Snapshot Format 14
    UInt32 dealValue;
    UInt32 innerPlat;
    UInt32 outerPlat;
    UInt32 captureTotalVolume;

	UInt8 snapshotTypeGet;

	NSMutableArray *warrantParamArray;
}
@property (nonatomic,strong) NSMutableArray *commodityArray;
@property (nonatomic,strong) NSMutableArray *warrantParamArray;

@end


@interface IndexSnapshot : NSObject{
@public
	UInt32 bidRecordCount;
	UInt32 askRecordCount;
	UInt32 bidVolume;
	UInt32 askVolume;
	UInt32 dealVolume;
	UInt32 dealRecordCount;
	UInt16 upSecurityNo;
	UInt16 downSecurityNo;
	UInt16 unchangedSecurityNo;
}

@end

@interface FutureOptionSnapshot : NSObject
{
@public
	UInt32 termHigh;
	UInt32 termLow;
	UInt32 settlement;
	UInt32 openInterest;
	UInt32 preOpenInterest;
}

@end

@interface WarrantSnapshot : NSObject
{
@public
	UInt32 strikePrice;		//履約價
}

@end

@class SymbolFormat1;
@interface WarrantParam : NSObject
{
	SymbolFormat1 *underlyingSecurity;	//標的物
@public
	double conversionRate;				//行使比例
}

@property (nonatomic,strong) SymbolFormat1 *underlyingSecurity;

- (id)initWithBuff:(UInt8*)buff ObjSize:(UInt16*)size Offset:(int*)offset;

@end




@interface SnapshotParam : NSObject {
@public
	UInt32 security;
	NSString *identCodeSymbol;
	Snapshot *snapshot;
}
@property (nonatomic,strong) Snapshot *snapshot;
@end

typedef enum
{
	kEquityPriceNormal = 0,
	kEquityPriceLockToCeiling = 4,
	kEquityPriceLockToFloor = 5,
	kEquityPriceGoingUp = 6,
	kEquityPriceGoingDown = 7
} EquityPriceStatusType;


@interface EquitySnapshotDecompressed : NSObject
{
	UInt16 date;
    UInt16 timeOfLastTick;
	UInt8 statusOfEquity;	// One of the EquityPriceStatusType.
	UInt16 sequenceOfTick;
	double referencePrice;  //參考價
	double ceilingPrice;    //價格上限
	double floorPrice;      //價格下限
	double openPrice;       //開盤價
	double highestPrice;    //最高價
	double lowestPrice;     //最低價
	double currentPrice;    //現價
	double bid;             //買價
	double ask;             //賣價
	double volume;          //量
	UInt16 volumeUnit;		// Unit of vlume, one of VolumeUnitType.
	double accumulatedVolume;
	UInt16 accumulatedVolumeUnit;	// Unit of vlume, one of VolumeUnitType.
	double previousVolume;
	UInt16 previousVolumeUnit;
	UInt8 commodityType;
    UInt8 tradeWarningCode;				//處置股票代碼: 00 ＝ 正常、01 ＝ 注意、02 ＝處置、03 ＝ 注意及處置、04 ＝ 再次處置、05 ＝ 注意及再次處置、06 ＝ 彈性處置、07 ＝ 注意及彈性處置
	UInt8 delayClose;					//延後收盤 0 or 1, 0 is NO, 1 is Yes
	UInt8 tradeSuspend;					//暫停交易on/off　0 or 1, 0 is 現在是沒有暫停交易, 1 is 現在是暫停交易 ..
	UInt32 tradeSuspendTime;			//暫停交易時間, 絕對時間 HH:MM:SS, 999999 代表目前沒有暫停交易時間. 顯示--.	
	UInt32 tradeResumeTime;				//恢復交易時間, 絕對時間 HH:MM:SS, 999999 如果有暫停交易時間, 代表時間尚未確認, 如果沒有暫停交易時間, 代表沒有恢復交易時間. 顯示--.
	UInt8 dailyStatusCode;				//1st bit=1: 異常推介. 2nd bit=1: 特殊異常. 其他bit reserved 填0 (MSB)
	
	UInt8  nearestBidAskCount;
	double strikePrice;		//warrant才會用到
	//Snapshot Format 2
	double week52High;
	double week52Low;
	//Snapshot Format 3
	double eps;                 //每股盈股
	UInt16 epsUnit;
	double annualDividend;		//一年紅利
	UInt16 annualDividendUnit;
	double currentAsset;		//資產淨值
	UInt16 currentAssetUnit;
	double issuedShares;		//發行股數
	UInt16 issuedSharesUnit;
	//Snapshot Format 4
	double averageVolume;		//3月均量
	UInt16 averageVolumeUnit;
	//Snapshot Format 5
	UInt16 settlementDay;
	NSMutableArray *warrantParamArray;
	//Snapshot Format 14 內外盤
    int innerPlat;		//內盤
	UInt16 innerPlatUnit;
    int outerPlat;		//外盤
	UInt16 outerPlatUnit;
	
	double *nearestBidPrice;
	double *nearestBidVolume;
	UInt16 *nearestBidVolumeUnit;
	double *nearestAskPrice;
	double *nearestAskVolume;
	UInt16 *nearestAskVolumeUnit;
	UInt8 snapshotTypeGet;
}

@property (nonatomic, readonly) UInt16 date;
@property (nonatomic, readonly) UInt16 timeOfLastTick;
@property (nonatomic, readonly) UInt8 statusOfEquity;	// One of the EquityPriceStatusType.
@property (nonatomic, readonly) UInt16 sequenceOfTick;
@property (nonatomic) double referencePrice;
@property (nonatomic) double ceilingPrice;
@property (nonatomic) double floorPrice;
@property (nonatomic) double openPrice;
@property (nonatomic) double highestPrice;
@property (nonatomic) double lowestPrice;
@property (nonatomic) double currentPrice;
@property (nonatomic, readonly) double bid;
@property (nonatomic, readonly) double ask;
@property (nonatomic) double volume;
@property (nonatomic, readonly) UInt16 volumeUnit;		// Unit of vlume, one of VolumeUnitType.
@property (nonatomic, readonly) double accumulatedVolume;
@property (nonatomic, readonly) UInt16 accumulatedVolumeUnit;	// Unit of vlume, one of VolumeUnitType.
@property (nonatomic) double previousVolume;
@property (nonatomic, readonly) UInt16 previousVolumeUnit;
@property (nonatomic, readonly) UInt8 commodityType;
@property (nonatomic, readonly) UInt8 tradeWarningCode;
@property (nonatomic, readonly) UInt8 delayClose;					//延後收盤 0 or 1, 0 is NO, 1 is Yes
@property (nonatomic, readonly) UInt8 tradeSuspend;					//暫停交易on/off　0 or 1, 0 is 現在是沒有暫停交易, 1 is 現在是暫停交易 ..
@property (nonatomic, readonly) UInt32 tradeSuspendTime;			//暫停交易時間, 絕對時間 HH:MM:SS, 999999 代表目前沒有暫停交易時間. 顯示--.	
@property (nonatomic, readonly) UInt32 tradeResumeTime;				//恢復交易時間, 絕對時間 HH:MM:SS, 999999 如果有暫停交易時間, 代表時間尚未確認, 如果沒有暫停交易時間, 代表沒有恢復交易時間. 顯示--.
@property (nonatomic, readonly) UInt8 dailyStatusCode;				//1st bit=1: 異常推介. 2nd bit=1: 特殊異常. 其他bit reserved 填0 (MSB)

@property (nonatomic, readonly) UInt8 nearestBidAskCount;
@property (nonatomic, readonly) double *nearestBidPrice;
@property (nonatomic, readonly) double *nearestBidVolume;
@property (nonatomic, readonly) UInt16 *nearestBidVolumeUnit;
@property (nonatomic, readonly) double *nearestAskPrice;
@property (nonatomic, readonly) double *nearestAskVolume;
@property (nonatomic, readonly) UInt16 *nearestAskVolumeUnit;

@property (nonatomic, readonly) UInt8 snapshotTypeGet;

@property (nonatomic, readonly) double strikePrice;
//Snapshot Format 2
@property (nonatomic, readonly) double week52High;
@property (nonatomic, readonly) double week52Low;
//Snapshot Format 3
@property (nonatomic, readonly) double eps;
@property (nonatomic, readonly) UInt16 epsUnit;
@property (nonatomic, readonly) double annualDividend;		//一年紅利
@property (nonatomic, readonly) UInt16 annualDividendUnit;
@property (nonatomic, readonly) double currentAsset;		//資產淨值
@property (nonatomic, readonly) UInt16 currentAssetUnit;
@property (nonatomic, readonly) double issuedShares;		//發行股數
@property (nonatomic, readonly) UInt16 issuedSharesUnit;
//Snapshot Format 4
@property (nonatomic, readonly) double averageVolume;		//3月均量
@property (nonatomic, readonly) UInt16 averageVolumeUnit;
//Snapshot Format 5
@property (nonatomic, readonly) UInt16 settlementDay;
@property (nonatomic, readonly) NSMutableArray *warrantParamArray;
//Snapshot Format 14
@property (nonatomic) int innerPlat;		//內盤
@property (nonatomic) UInt16 innerPlatUnit;
@property (nonatomic) int outerPlat;		//外盤
@property (nonatomic) UInt16 outerPlatUnit;

- (id) initWithEquitySanpshot:(Snapshot *)Snapshot;
- (void) setValueToAll:(Snapshot *)Snapshot;

- (void) updateWarningCode:(UInt8)warningCode;
- (void) updateDailyStatus:(UInt8)dailyStatus;
- (void) updateDelayClose:(UInt8)value;
- (void) updateWithTick:(EquityTickDataRef)tickParam andSeqNo: (UInt16)sequenceNo;
- (void) updateWithNearestBidAsk:(NSMutableArray*)array;
- (void) updateWithClear:(MessageType06Param *)tmParam;
- (void) updateWithOtherTypeSnapshot:(Snapshot*)snap;

@end

@interface IndexSnapshotDecompressed : EquitySnapshotDecompressed
{
	double bidRecordCount;
	UInt16 bidRecordCountUnit;
	double askRecordCount;
	UInt16 askRecordCountUnit;
	double bidVolume;
	UInt16 bidVolumeUnit;
	double askVolume;
	UInt16 askVolumeUnit;
	double dealVolume;
	UInt16 dealVolumeUnit;
	double dealRecordCount;
	UInt16 dealRecordCountUnit;
	UInt16 upSecurityNo;
	UInt16 downSecurityNo;
	UInt16 unchangedSecurityNo;
}

@property (nonatomic, readonly) double bidRecordCount;
@property (nonatomic, readonly) UInt16 bidRecordCountUnit;
@property (nonatomic, readonly) double askRecordCount;
@property (nonatomic, readonly) UInt16 askRecordCountUnit;
@property (nonatomic, readonly) double bidVolume;
@property (nonatomic, readonly) UInt16 bidVolumeUnit;
@property (nonatomic, readonly) double askVolume;
@property (nonatomic, readonly) UInt16 askVolumeUnit;
@property (nonatomic, readonly) double dealVolume;
@property (nonatomic, readonly) UInt16 dealVolumeUnit;
@property (nonatomic, readonly) double dealRecordCount;
@property (nonatomic, readonly) UInt16 dealRecordCountUnit;
@property (nonatomic, readonly) UInt16 upSecurityNo;
@property (nonatomic, readonly) UInt16 downSecurityNo;
@property (nonatomic, readonly) UInt16 unchangedSecurityNo;

- (id)initWithEquitySanpshot:(Snapshot *)Snapshot;
- (void) setValueToAll:(Snapshot *)Snapshot;

- (void) updateWithTick:(IndexTickDataRef)tickParam andSeqNo: (UInt16)sequenceNo;
- (void) updateWithOtherTypeSnapshot:(Snapshot*)snap;

@end


