//
//  EODTargetOut.m
//  FonestockPower
//
//  Created by Kenny on 2014/6/9.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "EODTargetOut.h"
#import "OutPacket.h"

@interface EODTargetOut() {
    UInt8 server_message;
    UInt8 server_command;
}
@end


@implementation EODTargetOut
- (instancetype)initWithSerialNumber:(UInt8)serialNumber PatternCount:(UInt8)patternCount Equation:(NSString *)equation Reserved:(UInt8)reserved
{
    if (self = [super init]) {
        _serialNumber = serialNumber;
        _patternCount = patternCount;
        _patternName = malloc(6 * sizeof(UInt8));
        _equation = equation;
        //_equation = [NSString stringWithFormat:@"(%@)", equation];
        _reserved = reserved;
        
        NSString * appid = [FSFonestock sharedInstance].appId;
        NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
        
        server_message = 13;
        if ([group isEqualToString:@"us"]) {
            server_command = 1;
        }else if ([group isEqualToString:@"cn"]){
            server_command = 3;
        }else{
            server_command = 2;
        }
    }
    return self;
}


- (int)getPacketSize {
    return (2 + 1 + 2 + 2) +  (1 + 1 + _patternCount * 6 + 2 + (int)[_equation length] + 1);
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len {
	char *tmpPtr = buffer;
    
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = server_message;
	phead->command = server_command;
    
	[CodingUtil setUInt16:(char *)&(phead->size) Value:len];
	buffer += sizeof(OutPacketHeader);
    
    // option 長度
    [CodingUtil setUInt16:buffer Value:3];
    buffer += 2;
    
    *buffer++ = 0x80;
    
    [CodingUtil setUInt16:buffer Value:333];
    buffer += 2;

    [CodingUtil setUInt16:buffer Value:(1 + 1 + _patternCount * 6 + 1 + 2 + [_equation length])];
    buffer += 2;
    
    *buffer++ = _serialNumber;
    
    *buffer++ = _patternCount;
    
	for (int j = 1; j < _patternCount+1; j++) {
        NSString *name = [NSString stringWithFormat:@"TPN%d",j];
        int count = 0;
        for(int i =0; i<name.length;i++){
            UInt8 pName = [name characterAtIndex:i];
            *buffer++ = pName;
            count ++;
        }
        for(int z = count;z<6; z++){
            *buffer++ = 0x00;
        }
    }
    
    [CodingUtil setUInt16:buffer Value:[_equation length]];
    buffer +=2;
//    NSLog(@"%@", _equation);
    strncpy(buffer, [_equation cStringUsingEncoding:NSASCIIStringEncoding], [_equation length]);
    buffer += [_equation length];

    
    *buffer++ = _reserved;
    
    buffer = tmpPtr;
	return YES;
}
@end
