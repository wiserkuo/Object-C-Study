//
//  FSSnapshotQueryIn.m
//  FonestockPower
//
//  Created by Connor on 14/7/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSSnapshotQueryIn.h"
#import "DecodeProtocol.h"
#import "NSNumber+Extensions.h"
#import "FSSnapshot.h"

@interface FSSnapshotQueryIn() <DecodeProtocol>

@end

@implementation FSSnapshotQueryIn

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode {
    UInt8 *ptr = body;

    NSMutableArray *snapshots = [[NSMutableArray alloc] initWithCapacity:5];
    NSMutableArray *snapshotIds = [[NSMutableArray alloc] initWithCapacity:5];
    
    int snapshotIdCount = *ptr++;
    for (int i = 0; i < snapshotIdCount; i++) {
        [snapshotIds addObject:[NSNumber numberWithInt:*ptr++]];
    }
    
    int snapshotResultCount = *ptr++;

    for (int i = 0; i < snapshotResultCount; i++) {
        NSString *identCodeSymbol = [CodingUtil getShortStringFormatByBuffer:&ptr needOffset:YES];
        
        NSLog(@"%@", identCodeSymbol);
        
        identCodeSymbol = [identCodeSymbol stringByReplacingOccurrencesOfString:@":" withString:@" "];
        
        PortfolioTick *tickBank = [[FSDataModelProc sharedInstance] portfolioTickBank];
        FSSnapshot *snapshot = [tickBank getSnapshotBvalueFromIdentCodeSymbol:identCodeSymbol];
        if (snapshot) {
            
        }
        else {
            snapshot = [[FSSnapshot alloc] init];
            snapshot.identCodeSymbol = identCodeSymbol;
        }
        
        PortfolioItem *item = [[[FSDataModelProc sharedInstance] portfolioData] findItemByIdentCodeSymbol:identCodeSymbol];
        if (item == nil) {
            
        } else {
            snapshot.securityNumber = item->commodityNo;
        }
        
        for (int j = 0; j < [snapshotIds count]; j++) {
            // snapshot_1
            if ([[snapshotIds objectAtIndex:j] isEqualToNumber:@1]) {
                [self decodeSnapshot1:&ptr snapshot:snapshot];
                snapshot.snapshotQueryFlag = YES;
            }
            // snapshot_2
            else if ([[snapshotIds objectAtIndex:j] isEqualToNumber:@2]) {
                [self decodeSnapshot2:&ptr snapshot:snapshot];
            }
            // snapshot_3
            else if ([[snapshotIds objectAtIndex:j] isEqualToNumber:@3]) {
                [self decodeSnapshot3:&ptr snapshot:snapshot];
            }
            // snapshot_4
            else if ([[snapshotIds objectAtIndex:j] isEqualToNumber:@4]) {
                [self decodeSnapshot4:&ptr snapshot:snapshot];
            } else {
                NSLog(@"未實作的Snapshot");
            }
        }
        [snapshots addObject:snapshot];
    }
}

- (void)decodeSnapshot1:(UInt8 **)sptr snapshot:(FSSnapshot *)snapshot {
    NSLog(@"snapshot_1");
    
    UInt8 *ptr = *sptr;
    
    int dataLength = *ptr++;
    
    if (dataLength) {
        UInt32 mask = [CodingUtil getUInt32:ptr];
        ptr += 4;
        
        if (mask & 1 << 0) {
            snapshot.trading_date = [[FSDateFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.tick_time = [[FSBTimeFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.reference_price = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.open_price = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.high_price = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.low_price = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.last_price = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.volume = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.accumulated_volume = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.previous_volume = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            
            
            
            
            
        }
        if (mask & 1 << 1) {
            snapshot.top_price = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.bottom_price = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            
        }
        if (mask & 1 << 2) {
//            NSLog(@"%d", 1 << 2);
            snapshot.bid_price = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.ask_price = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            
        }
        if (mask & 1 << 3) {
//            NSLog(@"%d", 1 << 3);
            snapshot.bid_volume = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.ask_volume = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            
        }
        if (mask & 1 << 4) {
//            NSLog(@"%d", 1 << 4);
            snapshot.deal_volume = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            
        }
        if (mask & 1 << 5) {
//            NSLog(@"%d", 1 << 5);
            snapshot.dealRecord = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.bidRecord = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.askRecord = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.bid_volume = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.ask_volume = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            
        }
        if (mask & 1 << 6) {
//            NSLog(@"%d", 1 << 6);
            snapshot.up_count = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.down_count = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.unchange_count = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            
        }
        if (mask & 1 << 7) {
//            NSLog(@"%d", 1 << 7);
            
            
        }
        if (mask & 1 << 8) {
//            NSLog(@"%d", 1 << 8);
            snapshot.inner_price = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.outer_price = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            
        }
        if (mask & 1 << 9) {
//            NSLog(@"%d", 1 << 9);
            
            
        }
        if (mask & 1 << 10) {
//            NSLog(@"%d", 1 << 10);
            
            
        }
        if (mask & 1 << 11) {
//            NSLog(@"%d", 1 << 11);
            
            
        }
        if (mask & 1 << 12) {
//            NSLog(@"%d", 1 << 12);
            
            
        }
        if (mask & 1 << 13) {
//            NSLog(@"%d", 1 << 13);
            
            
        }
        if (mask & 1 << 14) {
//            NSLog(@"%d", 1 << 14);
            
            
        }
        if (mask & 1 << 15) {
//            NSLog(@"%d", 1 << 15);
            
            
        }
        if (mask & 1 << 16) {
//            NSLog(@"%d", 1 << 16);
            
            
        }
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [dataModal.portfolioTickBank performSelector:@selector(updateEquitySnapshot:) onThread:dataModal.thread withObject:snapshot waitUntilDone:NO];
    }
    
    *sptr += dataLength + 1;
}

- (void)decodeSnapshot2:(UInt8 **)sptr snapshot:(FSSnapshot *)snapshot {
    NSLog(@"snapshot_2");
    
    UInt8 *ptr = *sptr;
    
    int dataLength = *ptr++;
    
    if (dataLength) {
        UInt16 mask = [CodingUtil getUInt16:ptr];
        ptr += 2;
        
        if (mask & 1 << 0) {
            snapshot.highest_52week_volume = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.lowest_52week_volume = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.average_3month_volume = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
        }
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [dataModal.portfolioTickBank performSelector:@selector(updateEquitySnapshot:) onThread:dataModal.thread withObject:snapshot waitUntilDone:NO];
    }
    *sptr += dataLength + 1;
}

- (void)decodeSnapshot3:(UInt8 **)sptr snapshot:(FSSnapshot *)snapshot {
    NSLog(@"snapshot_3");
    
    UInt8 *ptr = *sptr;
    
    int dataLength = *ptr++;
    
    if (dataLength) {
        UInt16 mask = [CodingUtil getUInt16:ptr];
        ptr += 2;
        
        if (mask & 1 << 0) {
            snapshot.cdp_ah = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.cdp_nh = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.cdp_nl = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.cdp_al = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.cdp = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
        }
        
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [dataModal.portfolioTickBank performSelector:@selector(updateEquitySnapshot:) onThread:dataModal.thread withObject:snapshot waitUntilDone:NO];
    }
    
    *sptr += dataLength + 1;
}

- (void)decodeSnapshot4:(UInt8 **)sptr snapshot:(FSSnapshot *)snapshot {
    NSLog(@"snapshot_4");
    
    UInt8 *ptr = *sptr;
    
    int dataLength = *ptr++;
    if (dataLength) {
        UInt16 mask = [CodingUtil getUInt16:ptr];
        ptr += 2;
        
        if (mask & 1 << 0) {
            snapshot.eps = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.annual_divided = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.total_equity = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
            snapshot.issued_shares = [[FSBValueFormat alloc] initWithByte:&ptr needOffset:YES];
        }
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [dataModal.portfolioTickBank performSelector:@selector(updateEquitySnapshot:) onThread:dataModal.thread withObject:snapshot waitUntilDone:NO];
    }
    
    *sptr += dataLength + 1;
}

- (void)decodeSnapshot5:(UInt8 **)sptr snapshot:(FSSnapshot *)snapshot {
    NSLog(@"snapshot_5 目前還未開發");

    
    return;
    
    
    UInt8 *ptr = *sptr;
    
    int dataLength = *ptr++;
    
    UInt16 mask = [CodingUtil getUInt16:ptr];
    ptr += 2;
    
    if (mask & 1 << 0) {
        
        // todo
        
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [dataModal.portfolioTickBank performSelector:@selector(updateEquitySnapshot:) onThread:dataModal.thread withObject:snapshot waitUntilDone:NO];
        
        *sptr += dataLength + 1;
    }
}

@end
