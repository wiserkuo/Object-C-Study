//
//  FSIndexIn.m
//  FonestockPower
//
//  Created by Neil on 2014/11/27.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSIndexIn.h"
#import "FSTickData.h"

@implementation FSIndexIn
- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode {
    UInt8 *ptr = body;
    
    NSMutableArray *tickArray = [[NSMutableArray alloc] init];
    
    FSTickData *tick = [[FSTickData alloc] initWithByte:ptr tickType:FSTickType4];
    tick.queryType = FSTickReceiveTypePush;
    tick.type = FSTickType4;
    tick.securityNumber = commodity;
    [tickArray addObject:tick];
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];

    [dataModal.portfolioTickBank performSelector:@selector(addTick:recv_complete:) withObject:tickArray withObject:[NSNumber numberWithBool:YES]];
    
}

@end
