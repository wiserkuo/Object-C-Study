//
//  Portfolio.h
//  FonestockPower
//
//  Created by Neil on 14/4/22.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PortfolioIn;
@class SecurityName;

@interface PortfolioItem : NSObject {
@public
	char identCode[2];
	NSString *symbol;
	UInt8  type_id;//商品類別 1股票 2權證 3指數? 4期貨? 5選擇權 6綜合指數
	UInt8  market_id;//28興櫃
	NSString *fullName;
	UInt32 commodityNo;
	int  referenceCount;
	int valueAdded; // 1: 加值自選 , 0:一般自選
	BOOL tmpPortfolioFlag;
    int alertState; //0:無 1:獲利 2:損失
}
@property (nonatomic, strong) NSNumber *valueForSorting;

- (NSString *)getIdentCodeSymbol;
- (BOOL)isIdentCodeSymbolEqual:(NSString *)identCodeSymbol;
- (BOOL)isEqualIdentCode: (char*)identCode Symbol: (NSString *)Symbol;
- (NSString *)getNamedAccordingToMarket;

- (void)setFocus;
- (void)killFocus;


- (void)setTickFocus;
- (void)killTickFocus;
@end

@interface Portfolio : NSObject{
    NSMutableArray  *portfolioArray;  // store PortfolioItem
	NSMutableArray  *watchListArray;  // Current selected group
    NSMutableArray *currentSeeWatchListArray;	//記錄現在看到哪一些 斷線重連後要重送
    BOOL firstIn;
    int currGroupID;
    NSRecursiveLock *lock;
    NSObject * targetObj;
    BOOL reloadFlag;
}

- (int) getCount;
- (void)setTarget:(id)target;

- (PortfolioItem*) getItemAt: (int)  position;
- (PortfolioItem*) getItem: (UInt32) commodityNo;
- (NSMutableArray*) getWatchListArray;
- (PortfolioItem*) getAllItem: (UInt32) commodityNo;
- (BOOL) AddItem: (SecurityName*) item;

- (void) selectGroupID: (int) groupID;

- (void) addWatchListItemByIdentSymbolArray:(NSArray*)isArray;		//下次加 會蓋掉前面的
- (void) addWatchListItemNewSymbolObjArray:(NSArray*)isArray;
- (void) removeWatchListItemByIdentSymbolArray;

- (void) setCommodityNo:(PortfolioIn *) pIn;

- (PortfolioItem*) findItemByIdentCodeSymbol:(NSString *)identCodeSymbol;
- (PortfolioItem*) findInPortfolio: (char*) identCode Symbol: (NSString*) symbol;
- (PortfolioItem*) findInPortfolio:(UInt32)commodityNo;

- (BOOL) isInWatchList: (char*) identCode Symbol: (NSString*) symbol;
- (void) RemoveItem: (char*) identCode andSymbol: (NSString*) symbol;
- (void)moveWatchList:(int)rowIndex ToRowIndex:(int)toRowIndex;
- (void)sortWatchlistArray:(BOOL) descending;
- (void)reSetNewWatchListToDB;


@end


