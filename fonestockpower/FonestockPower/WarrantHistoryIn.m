//
//  WarrantHistroyIn.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "WarrantHistoryIn.h"

@implementation WarrantHistoryIn
- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
    UInt16 dataCount = [CodingUtil getUInt16:&body needOffset:YES];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    self.dataArray = [[NSMutableArray alloc] init];
    for(int i = 0; i<dataCount ; i++){
        HistoryObject *obj = [[HistoryObject alloc] init];
        
        obj.dataDate = [CodingUtil getUInt16:&body needOffset:YES];
        obj.hv_30 = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES].calcValue;
        obj.hv_60 = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES].calcValue;
        obj.hv_90 = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES].calcValue;
        obj.hv_120 = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES].calcValue;
        obj.iv = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES].calcValue;
        obj.siv = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES].calcValue;
        obj.biv = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES].calcValue;
        obj.volume = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES].calcValue;
        
        [_dataArray addObject:obj];
    }
    
    [dataModel.warrant performSelector:@selector(warrantHistoryDataCallBack:) onThread:dataModel.thread withObject:self waitUntilDone:NO];
}
@end

@implementation HistoryObject
@end