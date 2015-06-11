//
//  MarginTradingIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/1/8.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"


@interface MarginTradingIn : NSObject <DecodeProtocol>{
@public
	NSMutableArray *marginTradingArray;
	UInt8 retCode;
	UInt32 commodityNum;
}

@property (nonatomic,retain) NSMutableArray *marginTradingArray;

@end

@interface MarginTradingParam : NSObject
{
@public
	UInt16 date;
	double usedAmount;
	UInt8 usedAmountUnit;
	double amountOffset;
	UInt8 amountOffsetUnit;
	double amountRatio;
	UInt8 amountRatioUnit;
	double usedShare;
	UInt8 usedShareUnit;
	double sharedOffset;
	UInt8 sharedOffsetUnit;
	double sharedRatio;
	UInt8 sharedRatioUnit;
	double offset;
	UInt8 offsetUnit;
}

@end
