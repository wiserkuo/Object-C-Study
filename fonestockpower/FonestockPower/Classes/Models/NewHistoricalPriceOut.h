//
//  NewHistoricalPriceOut.h
//  Bullseye
//
//  Created by Connor on 13/9/6.
//
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"

@interface NewHistoricalPriceOut : NSObject <EncodeProtocol>
{
    UInt32 _securityNumber;
	UInt8 _dataType;
	UInt8 _commodityType;
	UInt8 _queryType;
	UInt16 _startDate;
	UInt16 _endDate;
	UInt16 _count;
}

-(id)initWithSecurityNumber:(UInt32)securityNumber dataType:(UInt8)dataType commodityType:(UInt8)commodityType startDate:(UInt16)startDate endDate:(UInt16)endDate;

-(id)initWithSecurityNumber:(UInt32)securityNumber dataType:(UInt8)dataType commodityType:(UInt8)commodityType count:(UInt16)count;

@end
