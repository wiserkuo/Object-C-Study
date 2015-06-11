//
//  EsmData.h
//  Bullseye
//
//  Created by Ming-Zhe Wu on 2009/6/19.
//  Copyright 2009 telepaq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EsmPriceIn.h"

@class EsmPriceParam;
@class EsmBidAskParam;
@class EsmTraderInfo;
@interface EsmData : NSObject {
	
	NSRecursiveLock *dataLock;
	id notifyObj;
	id type19NotifyObj;
	
	NSMutableArray *bidDataArray;
	NSMutableArray *askDataArray;	
	
	double bidBestPrice;
	double askBestPrice;
	int priceType;
	
}

@property(nonatomic,strong) NSMutableArray *bidDataArray;
@property(nonatomic,strong) NSMutableArray *askDataArray;	
@property(nonatomic,readwrite) double bidBestPrice;
@property(nonatomic,readwrite) double askBestPrice;
@property(nonatomic,readwrite) int priceType;



- (void)decodeArrive:(EsmPriceParam*)obj;
- (void)messageType19Arrive:(EsmPriceParam*)esmPriceParam;

- (void)setTarget:(id)obj;

- (double)getBidBestPrice;
- (double)getSellBestPrice;
- (double)getBidTotalVolume;
- (double)getSellTotalVolume;
- (int)getBidDataCount;
- (int)getSellDataCount;
- (NSMutableDictionary *)getBidDataWithRowIndex:(int)index;
- (NSMutableDictionary *)getSellDataWithRowIndex:(int)index;

- (void)discardData;
- (void)cleanData;


@end
