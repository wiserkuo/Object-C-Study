//
//  SymbolSectorIdOut.m
//  FonestockPower
//
//  Created by Neil on 2014/10/28.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "SymbolSectorIdOut.h"
#import "OutPacket.h"

@implementation SymbolSectorIdOut

- (id)initWithIdentCode:(NSString *)ids Symbol:(NSString *)symbol
{
	if( self = [super init] )
	{
		identCode = ids;
		Symbol = symbol;
	}
	return self;
}

- (int)getPacketSize
{
	return 1000;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 1;
	phead->command = 7;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	buffer+=sizeof(OutPacketHeader);
    
    *buffer++ = [identCode characterAtIndex:0];
    *buffer++ = [identCode characterAtIndex:1];
    
    *buffer++ = [Symbol length];
    
	strncpy(buffer, [Symbol cStringUsingEncoding:NSASCIIStringEncoding], [Symbol length]);
    buffer += [Symbol length];
    
	return YES;
	
}


@end
