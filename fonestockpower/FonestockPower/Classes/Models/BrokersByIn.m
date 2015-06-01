//
//  BrokersByStockIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/6/12.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "BrokersByIn.h"

@implementation BrokersByStockIn

@synthesize brokersFormat1Array;

- (id)init
{
	if(self = [super init])
	{
		brokersFormat1Array = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	
	commodityNum = commodity;
	returnCode = retcode;
	recordDate = [CodingUtil getUInt16:tmpPtr];
	tmpPtr += 2;
	int count = *tmpPtr++;
	int offset = 0;
	for(int i=0 ; i<count ; i++)
	{
		int size = 0;
		BrokersFormat1 *bsFormat1 = [[BrokersFormat1 alloc] initWithBuffer:tmpPtr Offset:&offset ObjSize:&size];
		tmpPtr += size;
		[brokersFormat1Array addObject:bsFormat1];
	}
	
	
	//送出在這
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.brokers performSelector:@selector(decodeByStockArrive:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}

@end


@implementation BrokersByBrokerIn

@synthesize brokersFormat2Array;

- (id)init
{
	if(self = [super init])
	{
		brokersFormat2Array = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	
	commodityNum = commodity;
	returnCode = retcode;
	recordDate = [CodingUtil getUInt16:tmpPtr];
	tmpPtr += 2;
	brokerID = [CodingUtil getUInt16:tmpPtr];
	tmpPtr += 2;
	
	int count = *tmpPtr++;
	int offset = 0;
	for(int i=0 ; i<count ; i++)
	{
		int size = 0;
		BrokersFormat2 *bsFormat2 = [[BrokersFormat2 alloc] initWithBuffer:tmpPtr Offset:&offset ObjSize:&size];
		tmpPtr += size;
		[brokersFormat2Array addObject:bsFormat2];
	}
	
	
	//送出在這
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.brokers performSelector:@selector(decodeByBrokerArrive:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}

@end


@implementation BrokersByAnchorIn

@synthesize brokersFormat3Array;

- (id)init
{
	if(self = [super init])
	{
		brokersFormat3Array = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	
	commodityNum = commodity;
	returnCode = retcode;
	recordDate = [CodingUtil getUInt16:tmpPtr];
	tmpPtr += 2;
	brokerID = [CodingUtil getUInt16:tmpPtr];
	tmpPtr += 2;
	
	int count = *tmpPtr++;
	int offset = 0;
	for(int i=0 ; i<count ; i++)
	{
		int size = 0;
		BrokersFormat3 *bsFormat3 = [[BrokersFormat3 alloc] initWithBuffer:tmpPtr Offset:&offset ObjSize:&size];
		tmpPtr += size;
		[brokersFormat3Array addObject:bsFormat3];
	}
	
	//送出在這
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.brokers performSelector:@selector(decodeByAnchorArrive:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}

@end

@implementation NewBrokersByBrokerIn

@synthesize brokersFormat2Array;

- (id)init
{
    if(self = [super init])
    {
        brokersFormat2Array = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
    UInt8 *tmpPtr = body;
        
    commodityNum = commodity;
    returnCode = retcode;
    recordDate = [CodingUtil getUInt16:tmpPtr];
    tmpPtr += 2;
    brokerID = [CodingUtil getUInt16:tmpPtr];
    tmpPtr += 2;
    
    int count = *tmpPtr++;
    int offset = 0;
    for(int i=0 ; i<count ; i++)
    {
        int size = 0;
        BrokersFormat2 *bsFormat2 = [[BrokersFormat2 alloc] initWithBuffer:tmpPtr Offset:&offset ObjSize:&size];
        tmpPtr += size;
        [brokersFormat2Array addObject:bsFormat2];
    }
    
    
    //送出在這
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.brokers performSelector:@selector(decodeByNewBrokerArrive:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}

@end

#pragma mark BrokersFormat

@implementation BrokersFormat1

- (id)initWithBuffer:(UInt8*)tmpPtr Offset:(int*)offset ObjSize:(int*)size
{
	if(self = [super init])
	{
		UInt8 *firstPtr = tmpPtr;
		brokerID = [CodingUtil getUint16FromBuf:tmpPtr Offset:*offset Bits:16];
		tmpPtr += 2;

		TAvalueFormatData tmpTA;
		buyShare = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:offset TAstruct:&tmpTA];
		buyShareUnit = tmpTA.magnitude;
		sellShare = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:offset TAstruct:&tmpTA];
		sellShareUnit = tmpTA.magnitude;
		buyAmnt = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:offset TAstruct:&tmpTA];
		buyAmntUnit = tmpTA.magnitude;
		sellAmnt = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:offset TAstruct:&tmpTA];
		sellAmntUnit = tmpTA.magnitude;
		*size += (tmpPtr - firstPtr);
	}
	return self;
}

@end


@implementation BrokersFormat2

@synthesize symbolInfo;

- (id)initWithBuffer:(UInt8*)tmpPtr Offset:(int*)offset ObjSize:(int*)size
{
	if(self = [super init])
	{
		UInt8 *firstPtr = tmpPtr;
		UInt16 sf1Size = 0;
		symbolInfo = [[SymbolFormat1 alloc] initWithBuff:tmpPtr objSize:&sf1Size Offset:*offset];
		tmpPtr += sf1Size;
		
		TAvalueFormatData tmpTA;
		buyShare = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:offset TAstruct:&tmpTA];
		buyShareUnit = tmpTA.magnitude;
		sellShare = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:offset TAstruct:&tmpTA];
		sellShareUnit = tmpTA.magnitude;
		buyAmnt = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:offset TAstruct:&tmpTA];
		buyAmntUnit = tmpTA.magnitude;
		sellAmnt = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:offset TAstruct:&tmpTA];
		sellAmntUnit = tmpTA.magnitude;
		*size += (tmpPtr - firstPtr);
	}
	return self;
}

@end



@implementation BrokersFormat3

- (id)initWithBuffer:(UInt8*)tmpPtr Offset:(int*)offset ObjSize:(int*)size
{
	if(self = [super init])
	{
		UInt8 *firstPtr = tmpPtr;
		date = [CodingUtil getUint16FromBuf:tmpPtr Offset:*offset Bits:16];
		tmpPtr += 2;
		
		TAvalueFormatData tmpTA;
		buyShare = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:offset TAstruct:&tmpTA];
		buyShareUnit = tmpTA.magnitude;
		sellShare = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:offset TAstruct:&tmpTA];
		sellShareUnit = tmpTA.magnitude;
		buyAmnt = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:offset TAstruct:&tmpTA];
		buyAmntUnit = tmpTA.magnitude;
		sellAmnt = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:offset TAstruct:&tmpTA];
		sellAmntUnit = tmpTA.magnitude;
		*size += (tmpPtr - firstPtr);
	}
	return self;
}

@end