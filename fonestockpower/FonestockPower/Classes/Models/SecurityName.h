//
//  SecurityName.h
//  FonestockPower
//
//  Created by Neil on 14/4/22.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OptionSymbolSyncIn.h"

@class SymbolFormat1;
@class SymbolSyncIn;

@interface SecurityName : NSObject {
@public
	UInt16 catID;
	char   identCode[2];
	NSString *symbol;
	UInt8   type_id;
	NSString *fullName;
}


@end

@interface SecurityNameData : NSObject {
	NSMutableArray  *dataCacheArray;
	NSObject *notifyTarget;
	UInt16	currCatID;
	UInt16  latestDate;
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

- (SecurityName*) securityNameWithIdentCodeSymbol: (NSString*)aString;
- (NSMutableArray*) securityNameWithIdentCodeSymbols: (NSMutableArray*)array;
//- (void) initDatabase;
- (void) setTarget: (NSObject*) obj;
- (void) selectCatID: (UInt16) catID;
-(void)clearCurrID;
//- (int)  getCount;
//- (NSString*) getSymbolAt: (int) position;
//- (NSString*) getNameAt: (int) position;
//- (NSString *)getSecurityNameTitleAt: (int) position;
//- (SecurityName*) getItemAt: (int) position;
//- (BOOL) isCheckedAt: (int) position;
//- (BOOL) checkAt: (int) position;
//- (void) uncheckAt: (int) position;
//
//- (void)sortDataBy:(NSInteger)option;
//
-(NSMutableArray *)searchGoods;
-(NSMutableArray *)searchMonthsWithFullName:(NSString *)fullName;
- (void) addSecurity:(SymbolSyncIn *) obj;
- (void) addOneSecurity:(SymbolFormat1 *) obj;
//- (void) addOption:(OptionSymbolSyncIn *) obj;
//- (void) addOptionWithArray:(id)security SectorID:(NSNumber *)sectorID;
//- (void) addSecurityForSearch:(SecurityName *) add;
//- (void) localSearch:(SearchParam*) obj;
//- (void) updateSecurityName:(SecurityName *) update;

- (void) getAllSecurities;
- (void) addOption:(OptionSymbolSyncIn *) obj;
@end