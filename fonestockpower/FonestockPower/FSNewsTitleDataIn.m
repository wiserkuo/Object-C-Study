//
//  FSNewsTitleDataIn.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/8.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSNewsTitleDataIn.h"

@implementation FSNewsTitleDataIn

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
    NSMutableArray *newsArray = [NSMutableArray new];
    
    UInt8 *tmpPtr = body;
    
    UInt16 date = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    UInt16 rootSectorID = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    UInt16 count = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    
    for(int i = 0; i < count; i++){

        NewsTitleData *titleDataObj = [NewsTitleData new];
        titleDataObj.retCode = retcode;
        titleDataObj.date = date;
        titleDataObj.rootSectorID = rootSectorID;
        titleDataObj.newsContent = [[NewNewsContentFormat1 alloc]initWithByte:&tmpPtr needOffset:YES];

        [newsArray addObject:titleDataObj];
    }
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.newsDataModel performSelector:@selector(newsTitleDataCallBack:) onThread:dataModal.thread withObject:newsArray waitUntilDone:NO];
}

@end

@implementation NewsTitleData
@end
