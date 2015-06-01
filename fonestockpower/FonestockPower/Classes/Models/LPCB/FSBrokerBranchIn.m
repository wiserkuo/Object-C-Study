//
//  FSBrokerBranchIn.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSBrokerBranchIn.h"

@implementation FSBrokerBranchIn

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{

    _brokerBranchAdd = [[NSMutableArray alloc]init];
    _brokerBranchRemove = [[NSMutableArray alloc]init];
    
    UInt8 *tmpPtr = body;
    _returnCode = retcode;
    _date = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    UInt16 countAdd = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    
    for(int i = 0; i < countAdd; i++){
        
        BrokerBranchNameFormat *branchFormat = [[BrokerBranchNameFormat alloc]initWithByte:&tmpPtr needOffset:YES];
        [_brokerBranchAdd addObject:branchFormat];

    }
    UInt16 countRemove = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    
    for(int i = 0; i < countRemove; i++){
        NSString *branchFormat = [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
       
        [_brokerBranchRemove addObject:branchFormat];
    }
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    [dataModel.brokerBranchInfo performSelector:@selector(syncBrokerBranchInfo:) onThread:dataModel.thread withObject:self waitUntilDone:NO];

}


@end

@implementation BrokerBranchNameFormat
@synthesize brokerBranchID, brokerID, name;

-(instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset{
    if (self = [super init]) {
        UInt8 *ptr = *sptr;
        
        brokerBranchID = [CodingUtil getShortStringFormatByBuffer:&ptr needOffset:needOffset];
        brokerID = [CodingUtil getUInt16:&ptr needOffset:needOffset];
        name = [CodingUtil getShortStringFormatByBuffer:&ptr needOffset:needOffset];
        
        *sptr = ptr;
    }
    return self;
}

@end