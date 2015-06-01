//
//  HistoricalEPS.h
//  Bullseye
//
//  Created by Yehsam on 2009/2/4.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HistoricalEPSIn;
@interface HistoricalEPS : NSObject {
	NSString *identSymbol;
	NSRecursiveLock *datalock;
	NSMutableArray *mainArray;
	//id notifyObj;
	BOOL removeFlag;

	// for autoFetch.
	UInt32 autoFetingNo;
	UInt32 commodityNum;
	HistoricalEPS *fetchObj;
}

@property (nonatomic,assign) UInt32 commodityNum;
@property (nonatomic,assign) UInt32 autoFetingNo;
@property (nonatomic,strong) HistoricalEPS *fetchObj;
@property (weak, nonatomic) id notifyObj;

@property (nonatomic,copy) NSString *identSymbol;
@property (nonatomic,strong) NSMutableArray *mainArray;

- (void)loadFromIdentSymbol:(NSString*)is;
- (void)sendAndRead;
//- (void)decodeArrive:(NSMutableArray*)isArray;
- (void)decodeArrive:(HistoricalEPSIn*)obj;
- (void)sortArray;
- (void)setTargetNotify:(id)obj;
- (NSArray*)getAllocEPSArray;
- (void)saveToFile;
- (void)discardData;
- (void)changePage;
- (NSArray*)getCompanyEPSDate;
// for autoFetch.
- (int) autofetch: (NSString*)identCodeSymbol;
- (void) deleteFetchObj;

@end
