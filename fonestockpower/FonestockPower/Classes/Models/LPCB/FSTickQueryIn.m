//
//  FSTickQueryIn.m
//  FonestockPower
//
//  Created by Connor on 14/8/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSTickQueryIn.h"
#import "FSTickData.h"

@implementation FSTickQueryIn

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode {
    UInt8 *ptr = body;
    
    NSMutableArray *tickArray = [[NSMutableArray alloc] init];
    
    NSString *identCodeSymbol = [CodingUtil getShortStringFormatByBuffer:&ptr needOffset:YES];
    identCodeSymbol = [identCodeSymbol stringByReplacingOccurrencesOfString:@":" withString:@" "];
    
    char queryMethod = *ptr++;
    
    int count = [CodingUtil getUInt32:ptr];
    ptr += 4;
    
    int messageType = *ptr++;
    
    NSLog(@"identCodeSymbol:%@ / queryMethod:%c / count:%d / messageType:%d", identCodeSymbol, queryMethod, count, messageType);
    
    for (int i = 0; i < count; i++) {
        int dataLength = *ptr++;
        
        FSTickData *tick = [[FSTickData alloc] initWithByte:ptr tickType:messageType];
        tick.type = messageType;
        tick.queryType = FSTickReceiveTypeQuery;
        tick.identCodeSymbol = identCodeSymbol;
        [tickArray addObject:tick];
        
        ptr += dataLength;
    }
    
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
