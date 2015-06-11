//
//  FSSnapshotQueryOut.m
//  FonestockPower
//
//  Created by Connor on 14/8/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSSnapshotQueryOut.h"
#import "OutPacket.h"

@interface FSSnapshotQueryOut() {
    NSArray *_snapshotTypes;
    NSArray *_identCodeSymbols;
}

@end

@implementation FSSnapshotQueryOut

- (instancetype)initWithSnapshotTypes:(NSArray *)snapshotTypes identCodeSymbols:(NSArray *)identCodeSymbols {
    if (self = [super init]) {
        _snapshotTypes = snapshotTypes;
        _identCodeSymbols = identCodeSymbols;
    }
    return self;
}

- (int)getPacketSize {
    int snapshot_type_column = 1;
    int snapshot_type_count = (int)[_snapshotTypes count];
    int ident_code_column = 1;
    int identCodeSymbolLength = 0;
    
    for (int i = 0; i < [_identCodeSymbols count]; i++) {
        identCodeSymbolLength += [[_identCodeSymbols objectAtIndex:i] length];
        identCodeSymbolLength ++;
    }
    
    return snapshot_type_column + snapshot_type_count + ident_code_column + identCodeSymbolLength;
}

- (BOOL)encode:(NSObject*)account1 buffer:(char*)buffer length:(int)len {
    
    char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 9;
	phead->command = 1;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
    
    *tmpPtr++ = [_snapshotTypes count];
    for (NSNumber *snapshotType in _snapshotTypes) {
        *tmpPtr++ = [snapshotType intValue];
    }
    
    *tmpPtr++ = [_identCodeSymbols count];
    
    for (NSString *identCodeSymbolString in _identCodeSymbols) {
        
        NSString *identCodeSymbol = [identCodeSymbolString stringByReplacingOccurrencesOfString:@" " withString:@":"];
        
        *tmpPtr++ = [identCodeSymbol length];
        strncpy(tmpPtr, [identCodeSymbol cStringUsingEncoding:NSASCIIStringEncoding], [identCodeSymbol length]);
        tmpPtr += [identCodeSymbol length];
    }
    
    return YES;
}
@end
