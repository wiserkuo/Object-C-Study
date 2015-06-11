//
//  BrokersIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/1/8.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"


@interface BrokersIn : NSObject <DecodeProtocol>{
@public
	UInt8 returnCode;
	UInt16 recordDate;
	NSMutableArray *brokersAddArray;
	NSMutableArray *brokersRemoveArray;
}

@property (readonly) NSMutableArray *brokersAddArray;
@property (readonly) NSMutableArray *brokersRemoveArray;

@end

@interface BrokersParam : NSObject
{
@public
	UInt8 brokerType;
	UInt16 brokerID;
	NSString *brokerName;
}

@property (nonatomic,copy) NSString *brokerName;

- (id)initWithBuffer:(UInt8*)tmpPtr Offset:(int*)offset ObjSize:(int*)size;

@end
