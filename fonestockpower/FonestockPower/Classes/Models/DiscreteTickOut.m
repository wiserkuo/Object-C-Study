//
//  DiscreteTickout.m
//  Bullseye
//
//  Created by Shen Kevin on 13/8/6.
//
//

#import "DiscreteTickOut.h"
#import "OutPacket.h"

@interface DiscreteTickOut ()

@property (nonatomic) UInt32 commodityNum;
@property (nonatomic) UInt16 beginSN;
@property (nonatomic) UInt16 endSN;
@property (nonatomic) UInt8 tickSnDivideRatio;

@end

@implementation DiscreteTickOut

- (id)initWithCommodityNum:(UInt32)aCommodityNum beginSN:(UInt16)aBeginSN endSN:(UInt16)anEndSN tickSnDivideRatio:(UInt8)aTickSnDivideRatio {
    if ((self = [super init])) {
        _commodityNum = aCommodityNum;
        _beginSN = aBeginSN;
        _endSN = anEndSN;
        _tickSnDivideRatio = aTickSnDivideRatio;
    }
    return self;
}


- (int)getPacketSize
{
    return 9;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 1;
	phead->command = 28;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	buffer+=sizeof(OutPacketHeader);
	
	[CodingUtil setUInt32:buffer Value:_commodityNum];
	buffer+=4;
    
    [CodingUtil setUInt16:buffer Value:_beginSN];
    buffer+=2;
    
    [CodingUtil setUInt16:buffer Value:_endSN];
    buffer+=2;
    
    [CodingUtil setUInt8:buffer value:_tickSnDivideRatio];
    buffer+=1;
	
	buffer = tmpPtr;
	
	return YES;
}

@end
