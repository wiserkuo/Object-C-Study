//
//  FSTickIn.m
//  FonestockPower
//
//  Created by Connor on 14/9/10.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSTickIn.h"
#import "FSTickData.h"

@implementation FSTickIn

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode {
    UInt8 *ptr = body;
    
    NSMutableArray *tickArray = [[NSMutableArray alloc] init];
    
    FSTickData *tick = [[FSTickData alloc] initWithByte:ptr tickType:FSTickType3];
    tick.queryType = FSTickReceiveTypePush;
    tick.type = FSTickType3;
    tick.securityNumber = commodity;
    [tickArray addObject:tick];
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    // retcode == 1 代表後面還有資料
    // retcode == 0 結束
    if (retcode == 0) {
        [dataModal.portfolioTickBank performSelector:@selector(addTick:recv_complete:) withObject:tickArray withObject:[NSNumber numberWithBool:YES]];
    }
    else if (retcode == 1) {
        [dataModal.portfolioTickBank performSelector:@selector(addTick:recv_complete:) withObject:tickArray withObject:[NSNumber numberWithBool:NO]];
    }
    
    
}
@end
