//
//  Option.h
//  Bullseye
//
//  Created by Yehsam on 2009/2/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Snapshot.h"

@class FutrueOptionTargetPriceIn;
@class OptionCallPut;
@class TargetPriceParam;
@class OptionBAData;

@protocol OptionDelegate
@required

@optional
- (void)notifyTickData;
- (void)NotifyBAData;

@end
@interface Option : NSObject {
	NSRecursiveLock *datalock;
	NSMutableArray *optionArray; 
	OptionBAData *optionBAData;  //五檔
	double targetPrice;
	double targetRefPrice;
	UInt32 focusSN;
	UInt16 time;
	UInt8 optionMonth;
	float callVol;
	float putVol;
	float callInterest;
	float putInterest;
	float callPreInterest;
	float putPreInterest;
	
	NSString *baseIdentSymbol;
	UInt16 baseYear;
	UInt16 baseMonth;
	
	//for order
	BOOL changeOrderPage;
}

@property (weak) NSObject<OptionDelegate> *notifyObj;
@property (weak) NSObject<OptionDelegate> *BAnotifyObj;

@property (nonatomic, retain) NSMutableArray *optionArray;
@property (nonatomic,retain) OptionBAData *optionBAData;
@property (readonly) double targetPrice;
@property (readonly) double targetRefPrice;

@property (readonly) UInt16 time;
@property (readonly) UInt8 optionMonth;
@property (nonatomic,copy) NSString *baseIdentSymbol;

@property (nonatomic, retain) NSMutableArray *goodsArray;
@property (nonatomic, retain) NSMutableArray *monthArray;
@property (unsafe_unretained, nonatomic) NSUInteger goodsNum;
@property (unsafe_unretained, nonatomic) NSUInteger monthNum;

- (void)sendAndRead:(NSString*)identSymbol Year:(UInt8)year Month:(UInt8)month;
- (void)optionPortfolioArrive:(NSArray*)opArray;
- (void)targetPriceArrive:(FutrueOptionTargetPriceIn*)tp;
- (void)snapshotArrive:(SnapshotParam*)ssParam;
- (void)tickArrive:(NSArray*)tick;
- (void)type14Arrive:(TargetPriceParam*)tpParam;
- (void)BAArrive:(NSArray*)baArray;
- (void)checkPriceFormat:(UInt32)val ToValue:(double*)toVal ReferencePrice:(double)ref;	//判斷是否有數 沒回傳nan
- (void)checkTAFormat:(UInt32)val ToValue:(double*)toVal Unit:(UInt16*)unit;	//判斷是否有數 沒回傳nan
- (void)sortArray;
- (void)discard;
- (OptionCallPut*)getNewRowData:(int)index;
- (OptionCallPut*)getDataByStrikePrice:(double)sp;
- (OptionBAData*)getAllocRowBAData:(int)index;
- (EquitySnapshotDecompressed*)getAllocBAData;
- (double)getStrikePriceByIndex:(int)index;
- (int)getRowByStrikePrice:(double)sp;
- (int)getRowCount;
- (int)getRowCountByStrikePrice:(double)sp;
- (double*)getNearestStrikePrice;
- (double*)getNearestStrikePrice4OptionOrder:(double)selectedStrikePrice;
- (BOOL)checkFocusSN:(UInt32)sn;
- (BOOL)checkSecurityNum:(UInt32)sn;
- (void)setFocus:(UInt32)securityNum Target:(id)obj;
- (void)unSetFocusSN;
- (float)getPCVol;
- (float)getPCIntest;
- (float)getPCPreIntest;

- (void)changeToOrderPage:(BOOL)changePage;	//YES是在下單
- (BOOL)orderPage;

@end

@class OptionParam;
@interface OptionCallPut : NSObject {
@public
	double strikePrice;	//履約價
	OptionParam *call;
	OptionParam *put;
}


@end

@interface OptionParam : NSObject {
	Snapshot *optionSnapshot;
	NSMutableArray *baArray;
@public
	UInt32 sn;
	double referencePrice;	//參考價
	double bid;		//買價
	double ask;		//賣價
	double openPrice;	//開盤價
	double highPrice;	//最高價
	double lowPrice;	//最低價
	double currentPrice;	//收盤價
	double settlement;	//結算價 收盤才用的到的樣子
	double openInterest;	//未平倉
	UInt16 openInterestUnit;
	double preInterest;		//昨倉
	UInt16 preInterestUnit;
	double volume;	//總量
	UInt16 volumeUnit;
	
}

@property (nonatomic,retain) Snapshot *optionSnapshot;
@property (nonatomic,retain) NSMutableArray *baArray;

@end

@interface OptionBAData : NSObject{
@public
	double bidPrice[5];
	double bidVolume[5];
	UInt16 bidVolumeUnit[5];
	double askPrice[5];
	double askVolume[5];
	UInt16 askVolumeUnit[5];
}


@end



