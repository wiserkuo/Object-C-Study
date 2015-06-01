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
#import "FSCategoryTree.h"
@interface RelatedNewsContent : NSObject {
@public	
	UInt32 related;
	UInt32 newsSN;
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
			  andRelated: (UInt32) newRelated 
			  andDate: (UInt16) newDate
			  andType: (UInt8) newType;

- (void)	setContent: (NSString*) newContent; 


@end


@interface RelatedNewsData : NSObject  {
	NSMutableArray  *dataCacheArray;
	NSObject  *notifyTarget;
	UInt32 relatedID;
	UInt32 commodityNo;
	NSString *identCodeSymbol;
//	sqlite3 *db;
	BOOL isDatabaseValid;
	NSRecursiveLock *lock;
	int newsCountLimit;

	// for autoFetch.
	UInt32 autoFetingCommodityNo; 
	UInt32 autoFetingNewsSN; 
	NSMutableArray *autofetchArray;
	int fetching, totalToFetch;
	
	// for see tmp news flag ( 暫存新聞 不回存到ＤＢ )
	BOOL seeTmpNews;
	NSString *tmpNewsContent;
}

@property (retain) NSObject *notifyTarget;
@property (nonatomic,retain) NSString *tmpNewsContent;

- (void) initDatabase;

- (void) setTarget: (NSObject *) obj;

- (int) selectRelated: (NSString*) identCodeSymbol;
- (int) getCount;
//- (void) reloadData;
- (NSString*) getTitleAt:(int)position andDate:(UInt16*)date andTime:(UInt16*)time andHadRead:(UInt8 *)hadRead andNewsSN:(UInt32*)newsSN;
- (NSString*) getContentAt:(int)position andSN:(UInt32)newsSN;

//- (int) getIndexByNewsSN:(int)newsSN;
//- (NSString*) getTitleByNewsSN:(UInt32)newsSN;
//- (NSString*) getContentByNewsSN:(UInt32)newsSN;
//- (void) requestContentFromServerByNewsSN:(UInt32)newsSN;

- (void) addWithTitle:(NewsRelateIn *) obj;
- (void) addWithContent:(NewsContentIn *) obj;

// for see tmp news
//- (void) setSeeTmpNews:(BOOL)bValue; //設定為暫存新聞 不回存到ＤＢ
//- (NSString *)getTmpNewsContent;
//- (void) selectRelated: (NSString*)identCodeSymbol startDate:(UInt16)startDate endDate:(UInt16)endDate;

@end
