//
//  SymbolSyncIn.h
//  Bullseye
//
//  Created by Yehsam on 2008/12/3.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecodeProtocol.h"


@interface SymbolSyncIn : NSObject <DecodeProtocol>{
@public
	UInt16 date;
	UInt16 year;
	UInt8 month;
	UInt8 day;
	UInt8 syncType;
	UInt16 sectorID;
	UInt16 countSymbol;
	NSMutableArray *dataArray;
	UInt8 retCode;
}

@property (nonatomic,retain) NSMutableArray *dataArray;

@end
