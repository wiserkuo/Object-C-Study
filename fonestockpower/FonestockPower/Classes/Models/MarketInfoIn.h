//
//  MarketInfoIn.h
//  Bullseye
//
//  Created by Yehsam on 2008/11/24.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecodeProtocol.h"


@interface MarketInfoIn : NSObject <DecodeProtocol>{
	UInt16 MITdate;
	UInt16 year;
	UInt8 month;
	UInt8 day;
	UInt8 addCount;
	UInt8 removeCount;
	NSMutableArray *marketAdd;
	NSMutableArray *marketRemove;	
	UInt8 retCode;
}

@property (nonatomic,strong) NSMutableArray *marketAdd;
@property (nonatomic,strong) NSMutableArray *marketRemove;

@end


@interface addMarket : NSObject{
@public
	UInt8 MarketID;
	UInt8 MarketInfoSize;	
	NSString *MarketName;
	char *CountryCode;
	UInt16 start_time1;
	UInt16 end_time1;
	UInt16 start_time2;
	UInt16 end_time2;
}

@end

@interface removeMarket : NSObject{
@public
	UInt8 MarketID;
}


@end

