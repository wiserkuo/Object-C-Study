//
//  VIPSNQueryOut.m
//  Bullseye
//
//  Created by Neil on 13/8/30.
//
//

#import "VIPSNQueryOut.h"
#import "OutPacket.h"
#import "CodingUtil.h"

@implementation VIPSNQueryOut

- (id)initWithCount:(UInt8)c consultancyId:(UInt16 *)cId pdaItemId:(UInt8 *)pId days:(UInt8 *)d
{
	if(self = [super init])
	{
		count = c;
        consultancyId = malloc((count*sizeof(UInt16)));
		memcpy(consultancyId , cId , (count*sizeof(UInt16)));
        pdaItemId = malloc((count*sizeof(UInt8)));
		memcpy(pdaItemId , pId , (count*sizeof(UInt8)));
        
        days = malloc((count*sizeof(UInt8)));
		memcpy(days , d , (count*sizeof(UInt8)));

	}
	return self;
}

-(int)getPacketSize{
    return 1+(2*count*sizeof(UInt16));
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 5;
	phead->command = 3;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	buffer += sizeof(OutPacketHeader);
    
    *buffer++ = count;
    
	for(int i=0 ; i<count ; i++)
	{
		[CodingUtil setUInt16:buffer Value:consultancyId[i]];
		buffer+=2;
        *buffer++ = pdaItemId[i];
        *buffer++ = days[i];
        
	}

	buffer = tmpPtr;
	return YES;
}

- (void)dealloc
{
	if(consultancyId) free(consultancyId);
    if(pdaItemId) free(pdaItemId);
    if(days) free(days);
}

@end
