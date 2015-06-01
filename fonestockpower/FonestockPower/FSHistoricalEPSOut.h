//
//  FSHistoricalEPSOut.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSHistoricalEPSOut : NSObject <EncodeProtocol>{
    UInt32 commodityNum;
	UInt8 epsType;
	UInt8 count;
	UInt16 startDate;
	UInt16 endDate;
}

- (id)initWithStartDate:(UInt16)sd EndDate:(UInt16)ed CommodityNum:(UInt32)cn EPSType:(UInt8)et;
- (id)initWithCount:(UInt8)c CommodityNum:(UInt32)cn EPSType:(UInt8)et;

@end
