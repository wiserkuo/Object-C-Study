//
//  HistoricalEPSIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/1/8.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"


@interface HistoricalEPSIn : NSObject <DecodeProtocol>{
@public
	NSMutableArray *historicalEPSArray;
	UInt8 retCode;
	UInt32 commodityNum;
}

@property (nonatomic,strong) NSMutableArray *historicalEPSArray;

@end

@interface HistoricalEPSParam : NSObject
{
@public
	UInt8 epsType;
	UInt16 date;
	double epsValue;
	UInt8 epsValueUnit;
}

@end
