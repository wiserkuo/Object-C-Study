//
//  stockDataArrayoldIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/1/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@interface InvesterHoldIn : NSObject <DecodeProtocol>{
@public
	NSMutableArray *investerArray;
	UInt8 retCode;
	UInt32 commodityNum;
    double percent;
}

@property (nonatomic,retain) NSMutableArray *investerArray;

@end


@interface InvesterHoldData : NSObject
{
@public	
	UInt8 IIG_ID;
	UInt16 date;
	double ownShares;
	UInt8 ownSharesUnit;
	double ownRatio;
	UInt8 ownRatioUnit;
}

@end

