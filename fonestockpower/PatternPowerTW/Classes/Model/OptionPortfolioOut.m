//
//  OptionPortfolioOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/2/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OptionPortfolioOut.h"
#import "OutPacket.h"

static int stringSize = 0;

@implementation OptionPortfolioOut

@synthesize symbolArray;

- (id)initWithCallIndetCode:(char*)ic SymbolArray:(NSArray*)sa Year:(UInt16)y Month:(UInt8)m Action:(UInt8)ac
{
	if(self = [super init])
	{
		count = [sa count];
		identCode[0] = ic[0];
		identCode[1] = ic[1];
		self.symbolArray = sa;
		for(NSString *tmpString in sa)
		{
			stringSize = stringSize + (int)[tmpString lengthOfBytesUsingEncoding:NSASCIIStringEncoding]+1 ;  //+1是1個byte要存string的長度
		}
		year = y;
		month = m;
		callPut = 0;  //Call
		action = ac;
	}
	return self;
}

- (id)initWithPutIndetCode:(char*)ic SymbolArray:(NSArray*)sa Year:(UInt16)y Month:(UInt8)m Action:(UInt8)ac
{
	if(self = [super init])
	{
		count = [sa count];
		identCode[0] = ic[0];
		identCode[1] = ic[1];
		self.symbolArray = sa;
		for(NSString *tmpString in sa)
		{
			stringSize = stringSize + (int)[tmpString lengthOfBytesUsingEncoding:NSASCIIStringEncoding]+1 ;  //+1是1個byte要存string的長度
		}
		year = y;
		month = m;
		callPut = 1;  //Put
		action = ac;
	}
	return self;
}


- (int)getPacketSize{
	return 7+stringSize;
}

- (BOOL)encode:(NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 4;
	phead->command = 4;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
	*tmpPtr++ = count;
	memcpy(tmpPtr, identCode , 2);
	tmpPtr+=2;
	for(NSString *tmpString in symbolArray)
	{
		int tmpStringSize = (int)[tmpString lengthOfBytesUsingEncoding:NSASCIIStringEncoding];
		*tmpPtr++ = tmpStringSize;
		memcpy(tmpPtr, [tmpString cStringUsingEncoding:NSASCIIStringEncoding] , tmpStringSize);
		tmpPtr += tmpStringSize;
	}
	*tmpPtr++ = year;
	*tmpPtr++ = month;
	*tmpPtr++ = callPut;
	*tmpPtr = action;
	
	return YES;
}

@end
