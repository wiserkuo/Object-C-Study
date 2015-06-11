//
//  InvesterHoldOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/1/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"


@interface InvesterHoldOut : NSObject <EncodeProtocol>{
	UInt32 commodityNum;
	UInt8 IIG_ID;	//	Institutional invester group table
	UInt16 startDate;
	UInt16 endDate;
}

- (id)initWithCommodityNum:(UInt32)cn IIG_ID:(UInt8)iid StartDate:(UInt16)sDate EndDate:(UInt16)eDate;

@end
