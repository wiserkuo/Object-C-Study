//
//  FSNewsSnDataIn.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/8.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSNewsSnDataIn.h"

@implementation FSNewsSnDataIn

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
    NSMutableArray *newsArray = [NSMutableArray new];
    
    UInt8 *tmpPtr = body;
    
    UInt16 rootSectorID = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    UInt16 date = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    UInt8 count = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
    
    for(int i = 0; i < count; i++){
        UInt16 sectorID = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
        UInt16 sn = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
        
        
        NewsSnData *dataObj = [NewsSnData new];
        dataObj.rootSectorID = rootSectorID;
        dataObj.date = date;
        dataObj.sectorID = sectorID;
        dataObj.sn = sn;

        [newsArray addObject:dataObj];
    }
        
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.newsDataModel performSelector:@selector(newsSnDataCallBack:) onThread:dataModal.thread withObject:newsArray waitUntilDone:NO];
}

@end

@implementation NewsSnData
@end
