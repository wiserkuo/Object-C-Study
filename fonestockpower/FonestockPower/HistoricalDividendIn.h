//
//  HistoricalDividendIn.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoricalDividendIn : NSObject <DecodeProtocol>
{
@public
    NSMutableArray *historicalDividendArray;
}

@end
@interface HistoricalDividendParam : NSObject
{
@public
	UInt16 date;
	NSString *emDiv;
	UInt8 emDivUnit;
	NSString *capDiv;
	UInt8 capDivUnit;
	NSString *cshDiv;
	UInt8 cshDivUnit;
}

@end
