//
//  EsmData.m
//  Bullseye
//
//  Created by Ming-Zhe Wu on 2009/6/19.
//  Copyright 2009 telepaq. All rights reserved.
//

#import "EsmData.h"
#import "EsmTraderInfo.h"
#import "MessageType19.h"
#import "RealtimeListController.h"

@implementation EsmData

@synthesize bidDataArray;
@synthesize askDataArray;
@synthesize bidBestPrice;
@synthesize askBestPrice;
@synthesize priceType;

- (id)init
{
	if(self = [super init])
	{
		dataLock = [[NSRecursiveLock alloc] init];
	}
	return self;
}


/* EsmPriceParam
 
 NSMutableArray *bidDataArray;	//存EsmBidAskParam
 NSMutableArray *askDataArray;
 @public
 UInt8 priceType;		//送出的價格種類，分別為只有B, 只有S和B and S都送這三種	0 : B	1 : S	2 : B and S (for snapshot)
 double bidBestPrice;		//買進最佳價格
 UInt8 bidCounts;			//買進報價的券商數目
 double askBestPrice;		//賣出最佳價格
 UInt8 askCounts;			//賣出報價的券商數目	 
 
 */


/* EsmBidAskParam
 
 UInt16 brokerID;			// broker id (4位數字)
 UInt16 traderTelephoneID;
 double volume;				//券商提供的買價量
 UInt8 volumeUnit;
 
 */


/* EsmTraderParam
 
 NSString *traderName;
 NSString *traderTele;
 @public
 UInt16 traderID;
 
 */


- (void)decodeArrive:(EsmPriceParam*)obj
{
	[dataLock lock];
	
	// 送出的價格種類，分別為只有B, 只有S和B and S都送這三種
	//0 : B
	//1 : S
	//2 : B and S (for snapshot)
	
	if(bidDataArray==nil)
	{
		bidDataArray = [[NSMutableArray alloc]init];
	
	}
		
	
	if(askDataArray==nil){
		
		askDataArray = [[NSMutableArray alloc]init];	
	
	}
	
	[self cleanData];	
	
	
	if(obj->priceType==0)
	{
		self.bidDataArray = obj.bidDataArray;
		bidBestPrice = obj->bidBestPrice;
		priceType = 0;
	
	}
	
	else if(obj->priceType==1)
	{
		
		self.askDataArray = obj.askDataArray;	 
		askBestPrice = obj->askBestPrice;
		priceType = 1;		
	
	}
	else if(obj->priceType==2)	
	{
		self.bidDataArray = obj.bidDataArray;
		bidBestPrice = obj->bidBestPrice;
		
		self.askDataArray = obj.askDataArray;	 
		askBestPrice = obj->askBestPrice;
		
		priceType = 2;		
	
	}
	
	else
	{
		
		NSLog(@"the price type from receiver can not use");
	   [dataLock unlock];		
		return;
	
	}
	
	/*
	NSLog(@"decodeArrive");
	NSLog(@"bidDataArray count:%d",[bidDataArray count]);
	NSLog(@"askDataArray count:%d",[askDataArray count]);
	NSLog(@"priceType :%d",obj->priceType);	
	NSLog(@"----");
	 */
	
    if(notifyObj)
		[notifyObj performSelectorOnMainThread:@selector(esmDataDataArrive) withObject:nil waitUntilDone:NO];
	
	[dataLock unlock];
}

- (void)messageType19Arrive:(EsmPriceParam*)esmPriceParam{
	
	[dataLock lock];
	
	// 送出的價格種類，分別為只有B, 只有S和B and S都送這三種
	//0 : B
	//1 : S
	//2 : B and S (for snapshot)
	
	/*
	NSLog(@"messageType19Arrive");
	NSLog(@"bidDataArray count:%d",[esmPriceParam.bidDataArray count]);
	NSLog(@"askDataArray count:%d",[esmPriceParam.askDataArray count]);
	NSLog(@"priceType :%d",esmPriceParam->priceType);
	NSLog(@"----");	
	 */
	
	if(bidDataArray==nil)
		bidDataArray= [[NSMutableArray alloc]init];
	
	if(askDataArray==nil)
		askDataArray= [[NSMutableArray alloc]init];	
		
	
	if(esmPriceParam->priceType==0) 
	{
		
		if([bidDataArray count]>0)
			[bidDataArray removeAllObjects];
		
		self.bidDataArray = esmPriceParam.bidDataArray; // priceType = 0 or 1 都讀取 esmPriceParam.bidDataArray (esmPriceParam.askDataArray 為 空的)
		bidBestPrice = esmPriceParam->bidBestPrice;

	}
	
	else if(esmPriceParam->priceType==1) 
	{
		
		if([askDataArray count]>0)
			[askDataArray removeAllObjects];
		
		self.askDataArray = esmPriceParam.bidDataArray;	// priceType = 0 or 1 都讀取 esmPriceParam.bidDataArray (esmPriceParam.askDataArray 為 空的)
		askBestPrice = esmPriceParam->bidBestPrice;
				
	}
	else if(esmPriceParam->priceType==2)	
	{
		
		if([bidDataArray count]>0)
			[bidDataArray removeAllObjects];
		
		if([askDataArray count]>0)
			[askDataArray removeAllObjects];
		
		self.bidDataArray = esmPriceParam.bidDataArray;
		bidBestPrice = esmPriceParam->bidBestPrice;
		
		self.askDataArray = esmPriceParam.askDataArray;	 
		askBestPrice = esmPriceParam->askBestPrice;
		
	}
	
	else{
		
		[self cleanData];
	
	}
		
	if(notifyObj)
	[type19NotifyObj performSelectorOnMainThread:@selector(type19NotifyDataArrive) withObject:nil waitUntilDone:NO];	
	
	[dataLock unlock];
	
}


- (void)setTarget:(id)obj {
	
	[dataLock lock];
	
	notifyObj = obj;
	type19NotifyObj = obj;
	
	[dataLock unlock];
}

- (int)getBidDataCount{
	
	return (int)[bidDataArray count];

}

- (int)getSellDataCount{
	
	return (int)[askDataArray count];
	
}

- (double)getBidBestPrice{
	
	return bidBestPrice;

}

- (double)getSellBestPrice{
	
	return askBestPrice;

}

- (double)getBidTotalVolume{
	
	[dataLock lock];
	
	double totalVolume = 0;
	
	for(EsmBidAskParam *esBidParm in bidDataArray){
		
		double bidVolume = esBidParm->volume;
		int bidVolumeUnit = esBidParm->volumeUnit;
		
		totalVolume += bidVolume*(pow(1000,bidVolumeUnit));
	
	}	
	
	[dataLock unlock];
	
	return totalVolume;
		

}

- (double)getSellTotalVolume{
	
	[dataLock lock];
	
	double totalVolume = 0;
	
	for(EsmBidAskParam *esSellParm in askDataArray){
		
		double sellVolume = esSellParm->volume;
		int sellVolumeUnit = esSellParm->volumeUnit;
		
		totalVolume += sellVolume*(pow(1000,sellVolumeUnit));
	
	}
	
	[dataLock unlock];
	
	return totalVolume;

}


- (NSMutableDictionary *)getBidDataWithRowIndex:(int)index{
	
	[dataLock lock];
	
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	
	NSMutableDictionary *bidTmpDict = [[NSMutableDictionary alloc]init];
	
	EsmBidAskParam *esBidParm = [bidDataArray objectAtIndex:index];
		
	double bidVolume = esBidParm->volume;
	int bidVolumeUnit = esBidParm->volumeUnit;
	
	[bidTmpDict setObject:[NSNumber numberWithInt:bidVolume*(pow(1000,bidVolumeUnit))] forKey:@"volume"]; //量
	
	if([dataModal.brokerInfo getNameByID:esBidParm->brokerID]==nil) //券商名稱
		[bidTmpDict setObject:@"----" forKey:@"brokerName"];		
	else
		[bidTmpDict setObject:[dataModal.brokerInfo getNameByID:esBidParm->brokerID] forKey:@"brokerName"];		
	
	if([dataModal.esmTraderInfo getNameByID:esBidParm->traderTelephoneID]==nil) //營業員名稱
		[bidTmpDict setObject:@"" forKey:@"traderName"];
	else
		[bidTmpDict setObject:[dataModal.esmTraderInfo getNameByID:esBidParm->traderTelephoneID] forKey:@"traderName"];
		
	if([dataModal.esmTraderInfo getPhoneByID:esBidParm->traderTelephoneID]==nil) //營業員電話
		[bidTmpDict setObject:@"" forKey:@"traderPhone"];		
	else
		[bidTmpDict setObject:[dataModal.esmTraderInfo getPhoneByID:esBidParm->traderTelephoneID] forKey:@"traderPhone"];		
	
	
	[dataLock unlock];		
	
	return bidTmpDict;
	
    
	
	
}

- (NSMutableDictionary *)getSellDataWithRowIndex:(int)index{
	
	[dataLock lock];
	
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	
	NSMutableDictionary *sellTmpDict = [[NSMutableDictionary alloc]init];	
	
	EsmBidAskParam *esSellParm = [askDataArray objectAtIndex:index];
		
	double sellVolume = esSellParm->volume;
	int sellVolumeUnit = esSellParm->volumeUnit;
	
	[sellTmpDict setObject:[NSNumber numberWithInt:sellVolume*(pow(1000,sellVolumeUnit))] forKey:@"volume"]; //量						
	
	if([dataModal.brokerInfo getNameByID:esSellParm->brokerID]==nil) //券商名稱
		[sellTmpDict setObject:@"----" forKey:@"brokerName"];		
	else
		[sellTmpDict setObject:[dataModal.brokerInfo getNameByID:esSellParm->brokerID] forKey:@"brokerName"];		
	
	if([dataModal.esmTraderInfo getNameByID:esSellParm->traderTelephoneID]==nil) //營業員名稱
		[sellTmpDict setObject:@"" forKey:@"traderName"];
	else
		[sellTmpDict setObject:[dataModal.esmTraderInfo getNameByID:esSellParm->traderTelephoneID] forKey:@"traderName"];
	
	if([dataModal.esmTraderInfo getPhoneByID:esSellParm->traderTelephoneID]==nil) //營業員電話
		[sellTmpDict setObject:@"" forKey:@"traderPhone"];		
	else
		[sellTmpDict setObject:[dataModal.esmTraderInfo getPhoneByID:esSellParm->traderTelephoneID] forKey:@"traderPhone"];			
	[dataLock unlock];
	
	return sellTmpDict;
	
	
}



- (void)discardData
{
	[dataLock lock];
	
	notifyObj = nil;
	type19NotifyObj = nil;
	
	if(bidDataArray)bidDataArray = nil;
	
	if(askDataArray)askDataArray = nil;
	
	[dataLock unlock];
}

- (void)cleanData{
	
	if([bidDataArray count]>0)
		[bidDataArray removeAllObjects];
	
	if([askDataArray count]>0)
		[askDataArray removeAllObjects];
	
	bidBestPrice = -1;
	
	askBestPrice = -1;

}

@end

