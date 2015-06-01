//
//  FSBAQuery.m
//  FonestockPower
//
//  Created by Connor on 14/7/30.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSBAQuery.h"
#import "FSBAQueryOut.h"

@implementation FSBAQuery

- (void)sendWithIdentCodeSymbol:(NSString *)ids {
    ids = [ids stringByReplacingOccurrencesOfString:@" " withString:@":"];
    FSBAQueryOut *packetOut = [[FSBAQueryOut alloc] initWithIdentCodeSymbols:[NSArray arrayWithObject:ids]];
    [FSDataModelProc sendData:self WithPacket:packetOut];
}
@end
