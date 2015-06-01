//
//  InvesterBSIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/1/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"


@interface InvesterBSIn : NSObject <DecodeProtocol>{
@public
	NSMutableArray *investerArray;
	UInt8 retCode;
	UInt32 commodityNum;
}

@property (nonatomic,retain) NSMutableArray *investerArray;

@end

@interface InvesterBSData : NSObject
{
@public	
	UInt8 IIG_ID;
	UInt16 date;
	double buyShares;
	UInt8 buySharesUnit;
	double sellShares;
	UInt8 sellSharesUnit;
	double buySell;
	UInt8 buySellUnit;
}

@end
