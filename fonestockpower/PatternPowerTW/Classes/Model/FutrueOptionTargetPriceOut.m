//
//  FutrueOptionTargetPriceOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/2/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FutrueOptionTargetPriceOut.h"
#import "CodingUtil.h"
#import "OutPacket.h"

@implementation FutrueOptionTargetPriceOut

- (id)initWithTargetNumbers:(UInt32*)tn Counts:(UInt8)c
{
	if(self = [super init])
	{
		count = c;
		targetNumber = malloc(count * sizeof(UInt32));
		for(int i=0 ; i<count ; i++)
			targetNumber[i] = [CodingUtil getUInt32:&tn[i]];
	}
	return self;
}

- (int)getPacketSize
{
	return 1 + count*sizeof(UInt32);
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 1;
	phead->command = 10;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
	
	*tmpPtr++ = count;
	for(int i=0; i<count ; i++)
	{
		[CodingUtil setUInt32:tmpPtr Value:targetNumber[i]];
		tmpPtr += 4;
	}
	
	return YES;
}

@end
