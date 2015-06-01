//
//  NewSymbolKeywordOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/11/6.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"

@interface NewSymbolKeywordOut : NSObject <EncodeProtocol>{
	UInt8 searchBySectorIDorIdent;		//1. search by sector. 2.search by country code.
	UInt8 countIDtoSearch;
	UInt16 *sectorIDorIdent;
	UInt8 securityCount;		//要找的security type 的count. 0 表示所有的security type.
	UInt8 *securityType;		// 1.stock.2.warrant.3.index.4.future.5.option.6.market_index..7.etf.
	UInt8 count;
	UInt8 pageNo;
	UInt8 fieldType;
	UInt8 searchType;
	UInt8 length;
	NSString *keyword;
    
    BOOL searchBySectorID;
}

- (id)initWithSectorCount:(UInt8)sc SectorID:(UInt16*)sID countPage:(UInt8)c Page_No:(UInt8)p FieldType:(UInt8)f SearchType:(UInt8)s;
- (id)initWithSectorCount:(UInt8)sc SectorID:(UInt16*)sID countPage:(UInt8)c Page_No:(UInt8)p FieldType:(UInt8)f SearchType:(UInt8)s searchBySectorId:(BOOL)search;
- (id)initWithSectorCount:(UInt8)sc SectorID:(UInt16*)sID countPage:(UInt8)c Page_No:(UInt8)p FieldType:(UInt8)f SearchType:(UInt8)s searchGroup:(int)group;
- (id)initWithIdentCount:(UInt8)sc IdentCode:(UInt16*)ic countPage:(UInt8)c Page_No:(UInt8)p FieldType:(UInt8)f SearchType:(UInt8)s;
- (void)setSecurityCount:(UInt8)c SecurityType:(UInt8*)st;
- (void)setKeyword:(NSString*)k;

@end
