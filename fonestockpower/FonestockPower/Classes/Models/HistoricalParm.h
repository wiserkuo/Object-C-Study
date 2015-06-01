//
//  HistoricalParm.h
//  Bullseye
//
//  Created by Yehsam on 2008/12/18.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HistoricalParm : NSObject {
@public
	char type;
	UInt16 dataCount;
	UInt32 commodityNum;
	UInt8  retcode;
	NSMutableArray *historicalDataArray;
}

@property (nonatomic,strong) NSMutableArray *historicalDataArray;

@end

@interface HistoricalDataFormat1 : NSObject{
@public
	UInt16 date;
	UInt32 openPrice;
	UInt32 highPrice;
	UInt32 lowPrice;
	UInt32 closePrice;
	UInt32 volume;
	UInt32 openInterest;  //期貨才會有
}

@end

@interface HistoricalDataFormat2 : NSObject{
@public
	BOOL dateFlag;
	UInt16 date;
	UInt16 time;
	UInt32 openPrice;
	UInt32 highPrice;
	UInt32 lowPrice;
	UInt32 closePrice;
	UInt32 volume;
}

@end