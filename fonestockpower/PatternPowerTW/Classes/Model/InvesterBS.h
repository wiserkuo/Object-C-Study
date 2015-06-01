//
//  InvesterBS.h
//  Bullseye
//
//  Created by Yehsam on 2009/1/10.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InvesterBSIn;
@class InvesterHoldIn;

@protocol InvesterDelegate
@required

@optional
- (void)notifyInvesterBSData;
- (void)notifyInvesterHoldData;

@end

@interface InvesterBS : NSObject {
	NSString *identSymbol;
	NSRecursiveLock *datalock;
	NSMutableDictionary *mainDict;
    
	// for autoFetch.
	UInt32 autoFetingNo;
	UInt32 commodityNum;
	InvesterBS *fetchObj;
}

@property (weak) NSObject<InvesterDelegate> *notifyObj;

@property (nonatomic,assign) UInt32 commodityNum;
@property (nonatomic,assign) UInt32 autoFetingNo;
@property (nonatomic,retain) InvesterBS *fetchObj;

@property (nonatomic,copy) NSString *identSymbol;
@property (nonatomic,retain) NSMutableDictionary *mainDict;

@property (unsafe_unretained, nonatomic) BOOL IIG1;
@property (unsafe_unretained, nonatomic) BOOL IIG2;
@property (unsafe_unretained, nonatomic) BOOL IIG3;

- (void)loadFromIdentSymbol:(NSString*)is;
- (void)sendAndRead;
//- (void)decodeArrive:(NSMutableArray*)bsArray;
- (void)decodeInvesterBSArrive:(InvesterBSIn*)obj;
- (void)decodeInvesterHoldArrive:(InvesterHoldIn*)obj;
- (void)setTargetNotify:(id)obj;
- (void)saveToFile;
- (NSArray *)getAllDateArray;
- (int)getRowCount;
- (NSArray *)getRowDataWithIndex:(int)index;
- (NSArray *)getDataForTodayUse;
- (void)discardData;

// for autoFetch.
- (int) autofetch: (NSString*)identCodeSymbol;
- (void) deleteFetchObj;


- (UInt16)getLastRecordDate;
- (UInt16)getLastIIGRecordDate;

- (NSUInteger)getIIG1StatWithBetweenStartDate:(UInt16)startDate AndEndDate:(UInt16)endDate;
- (NSUInteger)getIIG2StatWithBetweenStartDate:(UInt16)startDate AndEndDate:(UInt16)endDate;
- (NSUInteger)getIIG3StatWithBetweenStartDate:(UInt16)startDate AndEndDate:(UInt16)endDate;
- (double)getIndexIIG1StatWithBetweenStartDate:(UInt16)startDate AndEndDate:(UInt16)endDate;
- (double)getIndexIIG2StatWithBetweenStartDate:(UInt16)startDate AndEndDate:(UInt16)endDate;
- (double)getIndexIIG3StatWithBetweenStartDate:(UInt16)startDate AndEndDate:(UInt16)endDate;
@end
