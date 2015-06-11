//
//  TradeDistributeIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/6/15.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"


@interface TradeDistributeIn : NSObject <DecodeProtocol>{
@public
	UInt32 securityNum;
	UInt8 returnCode;	//1還有封包
	UInt8 dayType;		//0:單日,1:累計 
	UInt8 dayCount;		//單日:前第幾日,累計:5,10,15 
	UInt16 date;		//資料日期 
	UInt16 startDate;	//統計起使日期
	UInt16 endDate;		//統計結束日期
	NSMutableArray *tdArray;	//存TradeDistributeParam
}

@property (nonatomic,readonly) NSMutableArray *tdArray;

@end


@interface TradeDistributeParam : NSObject
{
@public
	double price;
	double volume;
	UInt8 volumeUnit;
    double innerVolume;
    double outerVolume;
}
//@property (nonatomic, assign) double price;
//@property (nonatomic, assign) double volume;
//@property (nonatomic, assign) UInt8 volumeUnit;
@end

@interface NewTradeDistributeParam : NSObject
{
@public
	NSString * price;
    double highPrice;
	double volume;
	UInt8 volumeUnit;
}
@end
