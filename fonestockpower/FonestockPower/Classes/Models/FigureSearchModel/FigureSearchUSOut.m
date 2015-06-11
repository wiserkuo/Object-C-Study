//
//  FigureSearchUSOut.m
//  WirtsLeg
//
//  Created by Connor on 13/11/20.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FigureSearchUSOut.h"
#import "OutPacket.h"

@interface FigureSearchUSOut() {
    UInt8 server_message;
    UInt8 server_command;
}
@end

@implementation FigureSearchUSOut

- (instancetype)initWithFigureSearchUSFeeType:(enum FigureSearchUSFeeType)type SectorIDs:(UInt16 *)sectorIDs sectorIDsCount:(UInt8)sectorIDsCount flag:(UInt8)flag sn:(UInt8)sn reqCount:(UInt8)reqCount equationLen:(UInt16)equationLen equationString:(UInt8 *)equationString {
    
    if (self = [super init]) {
        _sectorCount = sectorIDsCount;
        _sectorIDs = sectorIDs;
        _flag = flag;
        _sn = sn;
        _reqCount = reqCount;
        _equationLen = equationLen;
        _equationString = equationString;
        
        NSString * appid = [FSFonestock sharedInstance].appId;
        NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
        
        switch (type) {
            case FigureSearchUSFeeTypePreviousSessionBuildIn:
                server_message = 150;
                if ([group isEqualToString:@"us"]) {
                    server_command = 1;
                }else if ([group isEqualToString:@"cn"]){
                    server_command = 5;
                }else{
                    server_command = 9;
                }
                break;
                
            case FigureSearchUSFeeTypeInSessionBuildIn:
                server_message = 150;
                if ([group isEqualToString:@"us"]) {
                    server_command = 2;
                }else if ([group isEqualToString:@"cn"]){
                    server_command = 6;
                }else{
                    server_command = 10;
                }
                break;
                
            case FigureSearchUSFeeTypePreviousSessionDIY:
                server_message = 150;
                if ([group isEqualToString:@"us"]) {
                    server_command = 3;
                }else if ([group isEqualToString:@"cn"]){
                    server_command = 7;
                }else{
                    server_command = 11;
                }
                break;
                
            case FigureSearchUSFeeTypeInSessionDIY:
                server_message = 150;
                if ([group isEqualToString:@"us"]) {
                    server_command = 4;
                }else if ([group isEqualToString:@"cn"]){
                    server_command = 8;
                }else{
                    server_command = 12;
                }
                break;
                
            default:
                break;
        }
    }
    return self;
}


- (int)getPacketSize {
    return (2 + 1 + 2 + 2) +  (1 + _sectorCount * 2 + 1 + 1 + 1 + 2 + _equationLen);
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
    
    [CodingUtil setUInt16:buffer Value:123];
    buffer += 2;
    
    [CodingUtil setUInt16:buffer Value:(1 + _sectorCount * 2 + 1 + 1 + 1 + 2 + _equationLen)];
    buffer += 2;
    
    *buffer++ = _sectorCount;
    
	for (int i = 0; i < _sectorCount; i++) {
        [CodingUtil setUInt16:buffer Value:_sectorIDs[i]];
        buffer += 2;
    }
    
    *buffer++ = _flag;
    *buffer++ = _sn;
    *buffer++ = _reqCount;
    
    [CodingUtil setUInt16:buffer Value:_equationLen];
    buffer += 2;
    
    for (int i = 0; i < _equationLen; i++) {
        *buffer++ = _equationString[i];
    }
    
    buffer = tmpPtr;
	return YES;
}
@end
