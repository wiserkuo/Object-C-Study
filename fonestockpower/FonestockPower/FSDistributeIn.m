//
//  FSDistributeIn.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/23.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSDistributeIn.h"

@implementation FSDistributeIn

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{
    tdArray = [[NSMutableArray alloc]init];
    returnCode = retcode;
    
    UInt8 *tmpPtr = body;
    
    NSString *identCodeSymbol;
    identCodeSymbol = [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
    
    dayType = *tmpPtr++;
    dayCount = *tmpPtr++;
    
    date = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    startDate = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    endDate = [CodingUtil getUInt16:&tmpPtr needOffset:YES];

    UInt16 count = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    
    for (int i = 0; i < count; i++){
        FSDistributeObj *disObj = [[FSDistributeObj alloc]init];
        
        disObj.price = [[FSBValueFormat alloc]initWithByte:&tmpPtr needOffset:YES];
        disObj.volume = [[FSBValueFormat alloc]initWithByte:&tmpPtr needOffset:YES];
        
        [tdArray addObject:disObj];
    }
    
    if (returnCode == 0) {
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [dataModal.tradeDistribute performSelector:@selector(fSDistributeIn:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
    }
    
    
    
}
@end

@implementation FSDistributeObj
@end
