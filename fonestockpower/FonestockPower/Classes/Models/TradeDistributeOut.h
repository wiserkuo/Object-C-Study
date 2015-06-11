//
//  TradeDistributeOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/6/15.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"


@interface TradeDistributeOut : NSObject <EncodeProtocol>{
	UInt32 securityNum;
	UInt8 dayType;		//0:單日,1:累計
	UInt8 dayCount;		//單日:前第幾日,累計:5,10,15	累計不含當日 
	UInt16 date;
}

- (id)initWithOneDaySecurityNum:(UInt32)cn DayCount:(UInt8)dc BeforeDate:(UInt16)d;
- (id)initWithAddDaySecurityNum:(UInt32)cn DayCount:(UInt8)dc BeforeDate:(UInt16)d;

@end
