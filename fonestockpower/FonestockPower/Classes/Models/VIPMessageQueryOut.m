//
//  VIPMessageQueryOut.m
//  Bullseye
//
//  Created by Neil on 13/9/3.
//
//

#import "VIPMessageQueryOut.h"
#import "OutPacket.h"

@implementation VIPMessageQueryOut

- (id)initWithConsultancyId:(UInt16)cId pdaItemId:(UInt8)pId askDate:(UInt16)d count:(UInt8)c type:(UInt8 *)t beginSerial:(UInt16 *)beginS endSerial:(UInt16 *)endS typeCount:(UInt8 *)typeC serial:(UInt16 *)s
{
	if(self = [super init])
	{
		count = c;
        size=0;
        consultancyId = cId;
        pdaItemId = pId;
        askDate = d;
        typeA = 0;
        typeB = 0;
        
        type = malloc((count*sizeof(UInt8)));
		memcpy(type , t , (count*sizeof(UInt8)));
        
        for (int i=0; i<count; i++) {
            if (type[i]==1) {
                typeA = typeA + 1;
                size = size+5;
                //NSLog(@"%d",typeA);
            }else{
                typeB = typeB + 1;
                size = size+4;
                //NSLog(@"%d",typeB);
            }
        }
        
        beginSerial = malloc((typeA*sizeof(UInt16)));
		memcpy(beginSerial , beginS , (typeA*sizeof(UInt16)));
        
        endSerial = malloc((typeA*sizeof(UInt16)));
		memcpy(endSerial , endS , (typeA*sizeof(UInt16)));
        
        typeCount = malloc((typeB*sizeof(UInt8)));
		memcpy(typeCount , typeC , (typeB*sizeof(UInt8)));
        
        serial = malloc((typeB*sizeof(UInt16)));
		memcpy(serial , s , (typeB*sizeof(UInt16)));
        
	}
	return self;
}

-(int)getPacketSize{
    NSLog(@"getSize:%d",size);
    return  6+(size * sizeof(UInt8));
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 5;
	phead->command = 2;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	buffer += sizeof(OutPacketHeader);
    
    [CodingUtil setUInt16:buffer Value:consultancyId];
    buffer+=2;
    
    *buffer++ = pdaItemId;
    
    [CodingUtil setUInt16:buffer Value:askDate];
    buffer+=2;
    
    *buffer++ = count;
    
	for(int i=0 ; i<count ; i++)
	{
        *buffer++ = type[i];
        if (type[i] == 1) {
            [CodingUtil setUInt16:buffer Value:beginSerial[i]];
            buffer+=2;
            [CodingUtil setUInt16:buffer Value:endSerial[i]];
            buffer+=2;
            NSLog(@"in type1");
        }else{
            *buffer++ = typeCount[i];
            [CodingUtil setUInt16:buffer Value:serial[i]];
            buffer+=2;
            NSLog(@"in type2");
        }
	}
    NSLog(@"Size:%d",size);
	buffer = tmpPtr;
	return YES;
}

- (void)dealloc
{
	if(type) free(type);
    if(beginSerial) free(beginSerial);
    if(endSerial) free(endSerial);
    if(typeCount) free(typeCount);
    if(serial) free(serial);

}

@end
