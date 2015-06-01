//
//  FSHistoricalEPSIn.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSHistoricalEPSIn : NSObject <DecodeProtocol>{
@public
	NSMutableArray *historicalEPSArray;
	UInt8 retCode;
	UInt32 commodityNum;
}
@end

@interface NewHistoricalEPSParam : NSObject
{
@public
	UInt8 epsType;
	UInt16 date;
	double epsValue;
	UInt8 epsValueUnit;
}
@end
