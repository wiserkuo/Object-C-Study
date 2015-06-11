//
//  FSJoinPacketIn.m
//  FonestockPower
//
//  Created by Neil on 2014/11/10.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSJoinPacketIn.h"

@implementation FSJoinPacketIn

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{
    UInt8 *ptr = body;
//    NSLog(@"commodity:%d",(unsigned int)commodity);
    NSMutableArray * idArray = [[NSMutableArray alloc]init];
    
    int count = *ptr++;
//    NSLog(@"count:%d",count);
    for (int i =0; i<count; i++) {
        int idNum = *ptr++;
        [idArray addObject:[NSNumber numberWithInt:idNum]];
//        NSLog(@"id:%d",idNum);
    }
    
    for (int i = 0; i<[idArray count]; i++) {
        UInt8 *tmpPtr = ptr;
        int idNum = [[idArray objectAtIndex:i]intValue];
        int dataLength = *tmpPtr++;

        if (idNum == 3) {
            NSMutableArray *tickArray = [[NSMutableArray alloc] init];
            
            FSTickData *tick = [[FSTickData alloc] initWithByte:tmpPtr tickType:FSTickType3];
            tick.queryType = FSTickReceiveTypePush;
            tick.type = FSTickType3;
            tick.securityNumber = commodity;
            [tickArray addObject:tick];
            
            FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
            [dataModal.portfolioTickBank performSelector:@selector(addTick:recv_complete:) withObject:tickArray withObject:[NSNumber numberWithBool:YES]];
            
        }
        else if(idNum == 31){
            UInt16 mask = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
            if (mask & 1 << 0) {
//                NSLog(@"BlockNum:1");
                FSBValueFormat * avgPrice = [[FSBValueFormat alloc] initWithByte:&tmpPtr needOffset:YES];
//                NSLog(@"AVG Price:%f",avgPrice.calcValue);
            }
            if (mask & 1 << 1) {
//                NSLog(@"BlockNum:2");
                FSBValueFormat * inner = [[FSBValueFormat alloc] initWithByte:&tmpPtr needOffset:YES];
                FSBValueFormat * outer = [[FSBValueFormat alloc] initWithByte:&tmpPtr needOffset:YES];
//                NSLog(@"inner:%f",inner.calcValue);
//                NSLog(@"outer:%f",outer.calcValue);
                
                FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
                FSSnapshot * snapShot = [dataModal.portfolioTickBank getSnapshotBvalue:commodity];
                
                snapShot.outer_price = outer;
                snapShot.inner_price = inner;
                
                [dataModal.portfolioTickBank performSelector:@selector(updateEquitySnapshot:) withObject:snapShot];

            }
        }
        ptr +=dataLength +1;
    }
}

@end
