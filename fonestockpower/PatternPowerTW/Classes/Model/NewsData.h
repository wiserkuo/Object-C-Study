//
//  NewsData.h
//  Bullseye
//
//  Created by steven on 2008/12/4.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsTitleIn.h"
#import "NewsContentIn.h"
#import "NewsRelateIn.h"
#import "NewsSNIn.h"

@interface NewsContent : NSObject {
@public	
	UInt32 newsSN;
	UInt16 SN;
	UInt16 catID;
	UInt16 date;
	UInt16 time;
	NSString *title;
	NSString *content;
	UInt8 hadRead;
	UInt8 type;
}

@property (readonly) NSString *title;
@property (readonly) NSString *content;


- (void)	setWithTitle: (NSString*) newTitle 
			  andCatID: (UInt16) newCatID 
			  andDate: (UInt16) newDate
			  andSN: (UInt16) newSN
			  andType: (UInt8) newType;

- (void)	setContent: (NSString*) newContent; 


@end


@interface NewsData : NSObject {
	NSMutableArray  *dataCacheArray;
	NSMutableArray  *newsMaxSN;
	NSObject *notifyTarget;
	UInt16	currCatID;
//	sqlite3 *db;
	BOOL isDatabaseValid;
	NSRecursiveLock *lock;
	int newsCountLimit;
	BOOL dataChanged;
	UInt32 readingNewsSN;

	// for autoFetch.
	UInt16 autoFetingCatID; 
	UInt32 autoFetingNewsSN; 
	NSMutableArray *autofetchArray;
	int fetching, totalToFetch;
}

@property (retain) NSObject *notifyTarget;

- (void) setTarget: (NSObject *) obj;
//- (int) selectCatID: (UInt16) catID;
//- (int) getCount;
//- (int) getSectorNotReadCount: (UInt16) catID;
//- (NSString*) getTitleAt:(int)position andDate:(UInt16*)date andTime:(UInt16*)time andHadRead:(UInt8 *)hadRead andNewsSN:(UInt32*)newsSN;
//- (NSString*) getContentAt:(int)position andSN:(UInt32)newsSN;

//- (void) addWithSNIn:(NewsSNIn *) obj;
//- (void) addWithTitle:(NewsTitleIn *) obj;
//- (void) addWithRealTimeTitle:(NewsContentFormat3 *) obj;
- (void) addWithContent:(NewsContentIn *) obj;
- (void) initDatabase;


@end
