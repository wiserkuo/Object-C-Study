//
//  MarginTrading.h
//  Bullseye
//
//  Created by Yehsam on 2009/1/12.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MarginTradingIn;
@interface MarginTrading : NSObject {
	NSString *identSymbol;
	NSRecursiveLock *datalock;
	NSMutableArray *mainArray;
	id notifyObj;
	
	// for autoFetch.
	UInt32 autoFetingNo;
	UInt32 commodityNum;
	MarginTrading *fetchObj;
}

@property (nonatomic,assign) UInt32 commodityNum;
@property (nonatomic,retain) MarginTrading *fetchObj;
@property (nonatomic,assign) UInt32 autoFetingNo;
@property (nonatomic,copy) NSString *identSymbol;
@property (nonatomic,retain) NSMutableArray *mainArray;

- (void)loadFromIdentSymbol:(NSString*)is;
- (void)sendAndRead;
//- (void)decodeArrive:(NSMutableArray*)bsArray;
- (void)decodeArrive:(MarginTradingIn*)obj;
- (void)setTargetNotify:(id)obj;
- (void)saveToFile;
- (void)sortArray;

- (NSArray *)getAllDateArray;
- (int)getRowCount;
- (NSArray *)getRowDataWithIndex:(int)index;
- (void)discardData;

// for autoFetch.
- (int) autofetch: (NSString*)identCodeSymbol;
- (void) deleteFetchObj;

- (UInt16)getLastRecordDate;
- (NSDictionary *)getIIG1StatWithBetweenStartDate:(UInt16)startDate AndEndDate:(UInt16)endDate;
@end
