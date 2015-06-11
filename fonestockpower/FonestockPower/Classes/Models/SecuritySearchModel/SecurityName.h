//
//  SecurityName.h
//  Bullseye
//
//  Created by steven on 2008/12/8.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryTree.h"
#import "DBManager.h"
#import "SymbolSyncIn.h"
#import "OptionSymbolSyncIn.h"
#import "AutoFetchProtocol.h"
#import "Commodity.h"
#import "CodingUtil.h"

/*
#define TYPE_STOCK              1	// 股票
#define TYPE_WARRANT            2	// 權證
#define TYPE_INDEX              3	// 指數
#define TYPE_FUTURE             4 	// 期貨
#define TYPE_OPTION             5	// 選擇權
#define TYPE_MARKET_INDEX       6	// 市場指數
#define TYPE_ETF                7	// 指數股票型基金
#define TYPE_NEWS               8	// 新聞
#define TYPE_OTHER              9	// 其它
#define TYPE_CURRENCY           10	// 匯率
#define TYPE_FUTURE_OPTION_TARGET 11	// 期貨選擇權的現貨價
#define TYPE_CONSULTANCY        12	// 投顧 
*/

/*
@protocol Notify
- (void) notify;
@end
*/
@interface SectorID : NSObject
{
	UInt16 group;
}

@property(nonatomic,readwrite) UInt16 group;

-(id)initWithID:(UInt16) ID;
@end

@interface NSString (identCodeSymbol)
+(NSString *) stringWithIdentCode: (char*)identCode Symbol: (NSString*)symbol;
+(NSString *) newWithIdentCode: (char*)identCode Symbol: (NSString*)symbol;
@end

@interface SecurityName : NSObject {
@public
	UInt16 catID;
	char   identCode[2];
	NSString *symbol;
	UInt8   type_id;
	NSString *fullName;
}
@property (nonatomic,copy) NSString *symbol;
@property (nonatomic,copy) NSString *fullName;

@end

@interface SearchParam : NSObject {
@public
	BOOL bsearchIdenCode;
	NSInteger idCount;
	UInt16* targetID;
	NSInteger typeCount;
	UInt8* targetType;
	NSInteger field_Type;
	NSInteger search_Type;
	NSString *keyword;
	
}
@end

@interface SecurityNameData : NSObject <AutoFetchProtocol> {
	NSMutableArray  *dataCacheArray;	
	NSObject <Notify>  *notifyTarget;
	UInt16	currCatID;
	UInt16  latestDate;
	DB_Date *db_Date;
//	sqlite3 *database;
	BOOL isDatabaseValid;
//	BOOL isDataReady;
	NSRecursiveLock *lock;

	// for autoFetch.
	UInt16 autoFetingCatID;  
	NSMutableArray *autofetchArray;
	int fetching, totalToFetch;
	
	NSMutableArray *replaceMarkUpArray; //遇到server replace指令, 先記住已經移除local table 的 sector data,
										// 已避免遇到分了多個封包, 卻重複刪除前一筆封包加入的local table data
}

@property (retain) NSObject <Notify> *notifyTarget;

- (SecurityName*) securityNameWithIdentCodeSymbol: (NSString*)aString;
- (NSMutableArray*) securityNameWithIdentCodeSymbols: (NSMutableArray*)array;
- (void) initDatabase;
- (void) setTarget: (NSObject <Notify>*) obj;
- (void) selectCatID: (UInt16) catID;
- (int)  getCount;
- (NSString*) getSymbolAt: (int) position;
- (NSString*) getNameAt: (int) position;
- (NSString *)getSecurityNameTitleAt: (int) position;
- (SecurityName*) getItemAt: (int) position;
- (BOOL) isCheckedAt: (int) position;
- (BOOL) checkAt: (int) position;
- (void) uncheckAt: (int) position;

- (void)sortDataBy:(NSInteger)option;

- (void) addSecurity:(SymbolSyncIn *) obj;
- (void) addOneSecurity:(SymbolFormat1 *) obj;
- (void) addOption:(OptionSymbolSyncIn *) obj;
- (void) addOptionWithArray:(id)security SectorID:(NSNumber *)sectorID;
- (void) addSecurityForSearch:(SecurityName *) add;
- (void) localSearch:(SearchParam*) obj;
- (void) updateSecurityName:(SecurityName *) update;
  
#ifdef GET_ALL_SECURITIES
// For Internal use only.
- (void) getAllSecurities;
#endif

@end
