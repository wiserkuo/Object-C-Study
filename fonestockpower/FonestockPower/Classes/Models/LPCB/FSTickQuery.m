//
//  FSTickQuery.m
//  FonestockPower
//
//  Created by Connor on 14/8/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSTickQuery.h"
#import "FSTickQueryOut.h"

@implementation FSTickQuery

- (void)send {
    FSTickQueryOut *packout = [[FSTickQueryOut alloc] initWithIdentCodeSymbol:@"US:GOOG"];
    [FSDataModelProc sendData:self WithPacket:packout];
}

@end
