//
//  BrokersByStockIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/6/12.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@interface BrokersByStockIn : NSObject <DecodeProtocol>{
@public
	UInt32 commodityNum;
	UInt8 returnCode;
	UInt16 recordDate;
	NSMutableArray *brokersFormat1Array;
}

@property (readonly) NSMutableArray *brokersFormat1Array;

@end


@interface BrokersByBrokerIn : NSObject <DecodeProtocol>{
@public
	UInt32 commodityNum;
	UInt16 brokerID;
	UInt8 returnCode;
	UInt16 recordDate;
	NSMutableArray *brokersFormat2Array;
}

@property (readonly) NSMutableArray *brokersFormat2Array;

@end


@interface BrokersByAnchorIn : NSObject <DecodeProtocol>{
@public
	UInt32 commodityNum;
	UInt16 brokerID;
	UInt8 returnCode;
	UInt16 recordDate;
	NSMutableArray *brokersFormat3Array;
}

@property (readonly) NSMutableArray *brokersFormat3Array;

@end

@interface NewBrokersByBrokerIn : NSObject <DecodeProtocol>{
@public
    UInt32 commodityNum;
    UInt16 brokerID;
    UInt8 returnCode;
    UInt16 recordDate;
    NSMutableArray *brokersFormat2Array;
}

@property (readonly) NSMutableArray *brokersFormat2Array;

@end


#pragma mark BrokersFormat

@interface BrokersFormat1 : NSObject
{
@public
	UInt16 brokerID;
	double buyShare;		//買張
	UInt8 buyShareUnit;
	double sellShare;		//賣張
	UInt8 sellShareUnit;
	double buyAmnt;			//買進金額
	UInt8 buyAmntUnit;
	double sellAmnt;		//賣出金額
	UInt8 sellAmntUnit;
    double buysellShare;
    UInt8 buysellAmnt;
}

- (id)initWithBuffer:(UInt8*)tmpPtr Offset:(int*)offset ObjSize:(int*)size;

@end



@interface BrokersFormat2 : NSObject
{
@public
	SymbolFormat1 *symbolInfo;
	double buyShare;		//買張
	UInt8 buyShareUnit;
	double sellShare;		//賣張
	UInt8 sellShareUnit;
	double buyAmnt;			//買進金額
	UInt8 buyAmntUnit;
	double sellAmnt;		//賣出金額
	UInt8 sellAmntUnit;
}

@property (nonatomic,strong) SymbolFormat1 *symbolInfo;

- (id)initWithBuffer:(UInt8*)tmpPtr Offset:(int*)offset ObjSize:(int*)size;

@end


@interface BrokersFormat3 : NSObject
{
@public
	UInt16 date;
	double buyShare;		//買張
	UInt8 buyShareUnit;
	double sellShare;		//賣張
	UInt8 sellShareUnit;
	double buyAmnt;			//買進金額
	UInt8 buyAmntUnit;
	double sellAmnt;		//賣出金額
	UInt8 sellAmntUnit;
}

- (id)initWithBuffer:(UInt8*)tmpPtr Offset:(int*)offset ObjSize:(int*)size;

@end
