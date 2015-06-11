//
//  Option.m
//  Bullseye
//
//  Created by Yehsam on 2009/2/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Option.h"
#import "OptionPortfolioOut.h"
#import "OptionPortfolioIn.h"
#import "PortfolioOut.h"
#import "FutrueOptionTargetPriceIn.h"
#import "CodingUtil.h"
#import "Tick.h"
#import "MessageType14.h"
#import "BADataIn.h"

static BOOL sortFlag = NO;
static int snapshotCount = 0;
static 	double returnSP[3];
static	double returnSP4OptionOrder[5]; // 0:strikePrice 1:call currentPrice  2:put currentPrice 3:call refPrice 4:put refPrice

@implementation Option

@synthesize optionArray;
@synthesize optionBAData;
@synthesize targetPrice,targetRefPrice;
@synthesize time;
@synthesize optionMonth;
@synthesize baseIdentSymbol;
@synthesize notifyObj;
@synthesize BAnotifyObj;

- (id)init
{
	if(self = [super init])
	{
		datalock = [[NSRecursiveLock alloc] init];
		optionArray = [[NSMutableArray alloc] init];
		focusSN = 0;
		callVol = 0;
		putVol = 0; 
		callInterest = 0;
		putInterest = 0;
		self.baseIdentSymbol = nil;
	}
	return self;
}

- (void)sendAndRead:(NSString*)identSymbol Year:(UInt8)year Month:(UInt8)month
{
	[datalock lock];
	if(baseIdentSymbol)
	{
		id tmpNotify = notifyObj;
		[self discard];
		notifyObj = tmpNotify;
	}
	self.baseIdentSymbol = identSymbol;
	baseYear = year;
	baseMonth = month;
	NSArray *tmpArray = [identSymbol componentsSeparatedByString:@" "];
	if([tmpArray count] < 2)
	{
		[datalock unlock];
		return;
	}
	NSString *identCode = [tmpArray objectAtIndex:0];
	NSString *symbol = [tmpArray objectAtIndex:1];
	char idc[2];
	memcpy(&idc , [identCode cStringUsingEncoding:NSASCIIStringEncoding] , 2);
	
	OptionPortfolioOut *opCallOut = [[OptionPortfolioOut alloc] initWithCallIndetCode:idc SymbolArray:[NSArray arrayWithObject:symbol] Year:year Month:month Action:1];
	[FSDataModelProc sendData:self WithPacket:opCallOut];
	OptionPortfolioOut *opPutOut = [[OptionPortfolioOut alloc] initWithPutIndetCode:idc SymbolArray:[NSArray arrayWithObject:symbol] Year:year Month:month Action:1];
	[FSDataModelProc sendData:self WithPacket:opPutOut];
	optionMonth = month;
	[datalock unlock];
}

- (void)optionPortfolioArrive:(NSArray*)opArray
{
	[datalock lock];
	OptionPortfolioParam *opParam = [opArray objectAtIndex:0];	//目前只有一個
	OptionCallPut *newOptionCallPut;
	for(StrikePriceParam *spParam in opParam.strikePriceArray)
	{
		BOOL findInArray = NO;
		for(OptionCallPut *tmp in optionArray)
		{
			if(tmp->strikePrice == spParam->strikePrice * pow(0.1,spParam->exponent))
			{
				newOptionCallPut = tmp;
				findInArray = YES;
				break;
			}
		}
		if(findInArray == NO) newOptionCallPut = [[OptionCallPut alloc] init];
		newOptionCallPut->strikePrice = spParam->strikePrice * pow(0.1,spParam->exponent);
		if(opParam->callPut == 0)
			newOptionCallPut->call->sn = spParam->sn;
		else
			newOptionCallPut->put->sn = spParam->sn;
		if(findInArray == NO)
		{
			[optionArray addObject:newOptionCallPut];
		}
	}
	[datalock unlock];
}

- (void)targetPriceArrive:(FutrueOptionTargetPriceIn*)tp
{
	[datalock lock];
	time = tp->targetPriceTime;
	targetPrice = tp->targetPrice;
	targetRefPrice = tp->targetRefPrice;
	
	[datalock unlock];
	
	
}

- (void)snapshotArrive:(SnapshotParam*)ssParam
{
	[datalock lock];
	if(sortFlag == NO) 
	{
		[self sortArray];
		sortFlag = YES;
	}
	
	for(OptionCallPut *option in optionArray)
	{
		OptionParam *tmp = nil;
		if(option->call->sn == ssParam->security) tmp=option->call;
		else if(option->put->sn == ssParam->security) tmp=option->put;
		if(tmp)
		{
			tmp.optionSnapshot = ssParam->snapshot;
			tmp->referencePrice = [CodingUtil ConvertPrice:ssParam->snapshot->referencePrice RefPrice:0];
			[self checkPriceFormat:ssParam->snapshot->bid ToValue:&tmp->bid ReferencePrice:tmp->referencePrice];
			[self checkPriceFormat:ssParam->snapshot->ask ToValue:&tmp->ask ReferencePrice:tmp->referencePrice];
			[self checkPriceFormat:ssParam->snapshot->openPrice ToValue:&tmp->openPrice ReferencePrice:tmp->referencePrice];
			[self checkPriceFormat:ssParam->snapshot->highestPrice ToValue:&tmp->highPrice ReferencePrice:tmp->referencePrice];
			[self checkPriceFormat:ssParam->snapshot->lowestPrice ToValue:&tmp->lowPrice ReferencePrice:tmp->referencePrice];
			[self checkPriceFormat:ssParam->snapshot->currentPrice ToValue:&tmp->currentPrice ReferencePrice:tmp->referencePrice];
			tmp->volume = [CodingUtil ConvertTAValue:ssParam->snapshot->accumulatedVolume WithType:&tmp->volumeUnit];
			FutureOptionSnapshot *futureOptionSnapshot = [ssParam.snapshot.commodityArray objectAtIndex:0];
			[self checkPriceFormat:futureOptionSnapshot->settlement ToValue:&tmp->settlement ReferencePrice:tmp->referencePrice];
			tmp->openInterest = [CodingUtil ConvertTAValue:futureOptionSnapshot->openInterest WithType:&tmp->openInterestUnit];
			tmp->preInterest = [CodingUtil ConvertTAValue:futureOptionSnapshot->preOpenInterest WithType:&tmp->preInterestUnit];
			if(option->call->sn == ssParam->security)
			{
				callVol += tmp->volume * pow(1000,tmp->volumeUnit);
				callInterest += tmp->openInterest;	
				callPreInterest += tmp->preInterest;
			}
			else if(option->put->sn == ssParam->security)
			{
				putVol += tmp->volume * pow(1000,tmp->volumeUnit);
				putInterest += tmp->openInterest;
				putPreInterest += tmp->preInterest;
			}
			break;
		}
	}
	snapshotCount++;
	if(snapshotCount == [optionArray count])
	{
		[notifyObj performSelectorOnMainThread:@selector(notifyData) withObject:nil waitUntilDone:NO];
		snapshotCount = 0;
	}
	[datalock unlock];
}

- (void)tickArrive:(NSArray*)tick
{
	[datalock lock];
	EquityTickParam *tickData = [tick objectAtIndex:0];
	if(tickData->etick.status > 5)
	{
		[datalock unlock];
		return;	//110: 趨漲(無以下欄位) 111: 趨跌(無以下欄位) 
	}
	OptionParam *newOption = nil;
	BOOL callputFlag = NO;
	for(OptionCallPut *tmpCallPut in optionArray)
	{
		if(tmpCallPut->call->sn == tickData->securityNO)
		{
			newOption = tmpCallPut->call;
			callVol -= newOption->volume * pow(1000,newOption->volumeUnit);
			callputFlag = YES;
			break;
		}
		if(tmpCallPut->put->sn == tickData->securityNO)
		{
			newOption = tmpCallPut->put;
			putVol -= newOption->volume * pow(1000,newOption->volumeUnit);
			callputFlag = NO;
			break;
		}
	}
	newOption->currentPrice = [CodingUtil ConvertPrice:tickData->etick.tick.price RefPrice:newOption->referencePrice] ;
	newOption->bid = [CodingUtil ConvertPrice:tickData->etick.bid RefPrice:newOption->currentPrice] ;
	newOption->ask = [CodingUtil ConvertPrice:tickData->etick.ask RefPrice:newOption->currentPrice];
	newOption->volume = [CodingUtil ConvertTAValue:tickData->etick.tick.volume WithType:&newOption->volumeUnit];
	if(callputFlag)
	{
		callVol += newOption->volume * pow(1000,newOption->volumeUnit);
	}
	else
	{
		putVol += newOption->volume * pow(1000,newOption->volumeUnit);
	}
	[datalock unlock];
	[notifyObj performSelectorOnMainThread:@selector(notifyTickData) withObject:nil waitUntilDone:NO];
}

- (void)type14Arrive:(TargetPriceParam*)tpParam
{
	[datalock lock];
	time = tpParam->targetPriceTime;
	targetPrice = tpParam->targetPrice;
	targetRefPrice = tpParam->targetRefPrice;
	
	[datalock unlock];
	[notifyObj performSelectorOnMainThread:@selector(notifyTickData) withObject:nil waitUntilDone:NO];
}

- (void)BAArrive:(NSArray*)baArray
{
	[datalock lock];
	int count = (int)[baArray count];
	OptionParam *optionData;
	OptionBAData *returnData = [[OptionBAData alloc] init];
	for(OptionCallPut *tmp in optionArray)
	{
		if(tmp->call->sn == focusSN)
		{
			optionData = tmp->call;
			break;
		}
		if(tmp->put->sn == focusSN)
		{
			optionData = tmp->put;
			break;
		}
	}
	optionData.baArray = (NSMutableArray*)baArray;
	if (count)
	{
		BADataParam *baParam = [baArray objectAtIndex:0];
		[self checkPriceFormat:baParam->bidPrice ToValue:&returnData->bidPrice[0] ReferencePrice:optionData->referencePrice];
		[self checkPriceFormat:baParam->askPrice ToValue:&returnData->askPrice[0] ReferencePrice:optionData->referencePrice];
		returnData->bidVolume[0] = [CodingUtil ConvertTAValue:baParam->bidVolume WithType:&returnData->bidVolumeUnit[0]];
		returnData->askVolume[0] = [CodingUtil ConvertTAValue:baParam->askVolume WithType:&returnData->askVolumeUnit[0]];
	}
	for (int i = 1; i < count; i++)
	{
		BADataParam *baParam = (BADataParam *)[baArray objectAtIndex:i];
		[self checkPriceFormat:baParam->bidPrice ToValue:&returnData->bidPrice[i] ReferencePrice:returnData->bidPrice[i-1]];
		[self checkPriceFormat:baParam->askPrice ToValue:&returnData->askPrice[i] ReferencePrice:returnData->askPrice[i-1]];
		returnData->bidVolume[i] = [CodingUtil ConvertTAValue:baParam->bidVolume WithType:&returnData->bidVolumeUnit[i]];
		returnData->askVolume[i] = [CodingUtil ConvertTAValue:baParam->askVolume WithType:&returnData->askVolumeUnit[i]];
	}
	for(int i=count ; i<5 ; i++)
	{
		[self checkPriceFormat:0 ToValue:&returnData->bidPrice[i] ReferencePrice:0];
		[self checkPriceFormat:0 ToValue:&returnData->askPrice[i] ReferencePrice:0];
		[self checkTAFormat:0 ToValue:&returnData->bidVolume[i] Unit:0];
		[self checkTAFormat:0 ToValue:&returnData->askVolume[i] Unit:0];
	}
//	if([baArray count]==0) self.optionBAData = nil;
	if(!self.optionBAData || count !=0)
		self.optionBAData = returnData;
	[datalock unlock];
	
	[BAnotifyObj performSelectorOnMainThread:@selector(NotifyBAData) withObject:nil waitUntilDone:NO];
}

- (void)sortArray
{
	NSSortDescriptor *sortDescriptor;
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"strikePrice" ascending:YES selector:@selector(compare:)];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	[optionArray sortUsingDescriptors:sortDescriptors];
}

- (void)checkPriceFormat:(UInt32)val ToValue:(double*)toVal ReferencePrice:(double)ref	//判斷是否有數 沒回傳nan
{
	if(val == 0)
		*toVal = [(NSNumber*)kCFNumberNaN doubleValue];
	else *toVal = [CodingUtil ConvertPrice:val RefPrice:ref];
}

- (void)checkTAFormat:(UInt32)val ToValue:(double*)toVal Unit:(UInt16*)unit	//判斷是否有數 沒回傳nan
{
	if(val == 0)
		*toVal = [(NSNumber*)kCFNumberNaN doubleValue];
	else *toVal = [CodingUtil ConvertTAValue:val WithType:unit];
}

- (void)discard
{
	[datalock lock];
	NSArray *tmpArray = [baseIdentSymbol componentsSeparatedByString:@" "];
	if([tmpArray count] < 2)
	{
		[datalock unlock];
		return;
	}
	NSString *identCode = [tmpArray objectAtIndex:0];
	NSString *symbol = [tmpArray objectAtIndex:1];
	char idc[2];
	memcpy(&idc , [identCode cStringUsingEncoding:NSASCIIStringEncoding] , 2);
	
	OptionPortfolioOut *opCallOut = [[OptionPortfolioOut alloc] initWithCallIndetCode:idc SymbolArray:[NSArray arrayWithObject:symbol] Year:baseYear Month:baseMonth Action:0];
	[FSDataModelProc sendData:self WithPacket:opCallOut];
	OptionPortfolioOut *opPutOut = [[OptionPortfolioOut alloc] initWithPutIndetCode:idc SymbolArray:[NSArray arrayWithObject:symbol] Year:baseYear Month:baseMonth Action:0];
	[FSDataModelProc sendData:self WithPacket:opPutOut];
	[optionArray removeAllObjects];
	self.optionBAData = nil;
	self.baseIdentSymbol = nil;
	BAnotifyObj = nil;
	sortFlag = NO;
	callVol = 0;
	putVol = 0; 
	callInterest = 0;
	putInterest = 0;
	callPreInterest = 0;
	putPreInterest = 0;
	targetPrice = 0;
	targetRefPrice = 0;
	[datalock unlock];
}

- (void)setFocus:(UInt32)securityNum Target:(id)obj;
{
	[datalock lock];
	BAnotifyObj = obj;
	focusSN = securityNum;
	PortfolioOut *packet = [[PortfolioOut alloc] init];
	[packet addFocusd:focusSN];
#if defined (BROKER_YUANTA) && !defined BROKER_GOLDEN_GATE
	[DataModalProc sendYuantadData:self WithPacket:packet];
#else
	[FSDataModelProc sendData:self WithPacket:packet];
#endif
	[datalock unlock];
}

- (void)unSetFocusSN
{
	[datalock lock];
	BAnotifyObj = nil;
	self.optionBAData = nil;
	if(focusSN)
	{
		PortfolioOut *packet = [[PortfolioOut alloc] init];
		[packet removeFocusd];
		[FSDataModelProc sendData:self WithPacket:packet];
	}
	focusSN = 0;
	[datalock unlock];
}

- (OptionCallPut*)getNewRowData:(int)index
{
	return [optionArray objectAtIndex:index];
}

- (OptionCallPut*)getDataByStrikePrice:(double)sp
{
	[datalock lock];
	OptionCallPut *returnOption = nil;
	for(OptionCallPut *tmp in optionArray)
	{
		if(tmp->strikePrice == sp)
		{
			returnOption = tmp;
			break;
		}
	}
	[datalock unlock];
	return returnOption;
}

- (double)getStrikePriceByIndex:(int)index
{
	OptionCallPut *tmpOption = [optionArray objectAtIndex:index];
	return tmpOption->strikePrice;
}

- (int)getRowByStrikePrice:(double)sp
{
	[datalock lock];
	int i=0;
	BOOL findFlag = NO;
	for(OptionCallPut *tmp in optionArray)
	{
		if(tmp->strikePrice == sp)
		{
			findFlag = YES;
			break;
		}
		i++;
	}
	[datalock unlock];
	if(findFlag) return i;
	else return 0;
}


- (double*)getNearestStrikePrice
{
	[datalock lock];
	BOOL findFlag = NO;
	BOOL zeroPrice = NO;
	for(OptionCallPut *tmp in optionArray)
	{
		if(findFlag)
		{
			returnSP[2] = tmp->strikePrice;
			break;
		}
		if((int)(tmp->strikePrice / targetPrice) == 1 || zeroPrice)
		{
			returnSP[1] = tmp->strikePrice;
			findFlag = YES;
			continue;
		}
		returnSP[0] = tmp->strikePrice;
		if(targetPrice == 0)
			zeroPrice = YES;
	}
	[datalock unlock];
	return returnSP;
}

- (double*)getNearestStrikePrice4OptionOrder:(double)selectedStrikePrice
{
	[datalock lock];
	//BOOL findFlag = NO;
	BOOL zeroPrice = NO;
	double userPrice = 0.0;
	if(selectedStrikePrice>=0)
	{
		userPrice = selectedStrikePrice;
	}
	else 
	{
		userPrice = targetPrice;
	}

	
	for(OptionCallPut *tmp in optionArray)
	{
		if(targetPrice == 0)
			zeroPrice = YES;
		if((int)(tmp->strikePrice / userPrice) == 1 || zeroPrice)
		{
			returnSP4OptionOrder[0] = tmp->strikePrice;
			if([[[NSNumber numberWithFloat:tmp->call->currentPrice] stringValue] isEqualToString:@"nan"])
			{
				if([[[NSNumber numberWithFloat:tmp->call->settlement] stringValue] isEqualToString:@"nan"])
				{
					returnSP4OptionOrder[1] = tmp->call->referencePrice;
				}	
				else 
				{
					returnSP4OptionOrder[1] = tmp->call->settlement;
				
				}
			}
			else 
			{
				returnSP4OptionOrder[1] = tmp->call->currentPrice;
				
			}
			returnSP4OptionOrder[3] = tmp->call->referencePrice;
			if([[[NSNumber numberWithFloat:tmp->put->currentPrice] stringValue] isEqualToString:@"nan"])
			{
				if([[[NSNumber numberWithFloat:tmp->put->settlement] stringValue] isEqualToString:@"nan"])
				{
					returnSP4OptionOrder[2] = tmp->put->referencePrice;
				}
				else
				{		
					returnSP4OptionOrder[2] = tmp->put->settlement;
				}
			}
			else 
			{
				returnSP4OptionOrder[2] = tmp->put->currentPrice;
				
			}	
			returnSP4OptionOrder[4] = tmp->put->referencePrice;
			break;
		}
			
		
//		if(findFlag)
//		{
//			returnSP4OptionOrder[2] = tmp->strikePrice;
//			break;
//		}
//		if((int)(tmp->strikePrice / targetPrice) == 1 || zeroPrice)
//		{
//			returnSP4OptionOrder[1] = tmp->strikePrice;
//			findFlag = YES;
//			continue;
//		}
//		returnSP4OptionOrder[0] = tmp->strikePrice;
//		if(targetPrice == 0)
//			zeroPrice = YES;
	}
	[datalock unlock];
	if(zeroPrice)
	{
		return nil;
	}
	else
	{
		return returnSP4OptionOrder;
	}
}

- (int)getRowCount
{
	return (int)[optionArray count];
}

- (int)getRowCountByStrikePrice:(double)sp
{
	[datalock lock];
	int i=0;
	for(OptionCallPut *tmp in optionArray)
	{
		if(tmp->strikePrice >= sp) i++;
	}
	[datalock unlock];
	return i;
}

- (OptionBAData*)getAllocRowBAData:(int)index;
{
	[datalock lock];
	if(optionBAData == nil)
	{
		[datalock unlock];
		return nil;
	}
	OptionBAData *returnData = [[OptionBAData alloc] init];
	returnData->bidPrice[0] = optionBAData->bidPrice[index];
	returnData->bidVolume[0] = optionBAData->bidVolume[index];
	returnData->bidVolumeUnit[0] = optionBAData->bidVolumeUnit[index];
	returnData->askPrice[0] = optionBAData->askPrice[index];
	returnData->askVolume[0] = optionBAData->askVolume[index];
	returnData->askVolumeUnit[0] = optionBAData->askVolumeUnit[index];
	[datalock unlock];
	return returnData;	//UI那要release
}

- (EquitySnapshotDecompressed*)getAllocBAData
{
	[datalock lock];
	OptionParam *optionData;
	for(OptionCallPut *tmp in optionArray)
	{
		if(tmp->call->sn == focusSN)
		{
			optionData = tmp->call;
			break;
		}
		if(tmp->put->sn == focusSN)
		{
			optionData = tmp->put;
			break;
		}
	}
	EquitySnapshotDecompressed *newData = [[EquitySnapshotDecompressed alloc] initWithEquitySanpshot:optionData.optionSnapshot];
	[newData updateWithNearestBidAsk:optionData.baArray];
	[datalock unlock];
	return newData;	//UI那要release
	
}


- (BOOL)checkSecurityNum:(UInt32)sn
{
	[datalock lock];
	BOOL flag = NO;
	for(OptionCallPut *tmpCallPut in optionArray)
	{
		if(tmpCallPut->call->sn == sn)
		{
			flag = YES;
		}
		if(tmpCallPut->put->sn == sn) flag = YES;
		if(flag) break;		
	}
	[datalock unlock];
	if(flag) return YES;
	else return NO;
}

- (BOOL)checkFocusSN:(UInt32)sn
{
	if(focusSN == sn) return YES;
	else return NO;
}

- (float)getPCVol
{
	if(callVol == 0)
		return [(NSNumber*)kCFNumberNaN floatValue];
	else
		return (float)(putVol / callVol);
}	

- (float)getPCIntest
{
	if(callInterest == 0)
		return [(NSNumber*)kCFNumberNaN floatValue];
	else
		return (float)(putInterest / callInterest);
}

- (float)getPCPreIntest
{
	if(callPreInterest == 0)
		return [(NSNumber*)kCFNumberNaN floatValue];
	else
		return (float)(putPreInterest / callPreInterest);
}


- (void)changeToOrderPage:(BOOL)changePage;	//YES是在下單
{
	changeOrderPage = changePage;
}

- (BOOL)orderPage
{
	return changeOrderPage;
}

- (void)deallc
{
	sortFlag = NO;
}

@end


@implementation OptionCallPut


- (id)init
{
	if(self = [super init])
	{
		call = [[OptionParam alloc] init];
		put = [[OptionParam alloc] init];
	}
	return self;
}

@end


@implementation OptionParam

@synthesize optionSnapshot;
@synthesize baArray;

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

@end

@implementation OptionBAData


- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}


@end


