//
//  FSMainPlusIn.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSMainPlusIn.h"

@implementation FSBrokerBranchByStockIn

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{
    NSMutableArray *brokerBranchStock = [[NSMutableArray alloc]init];
    
    UInt8 *tmpPtr = body;
    
    UInt16 identCode = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    NSString *symbol = [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
    UInt16 startDate = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    UInt16 endDate = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    
    FSBValueFormat *dealVolume = [[FSBValueFormat alloc]initWithByte:&tmpPtr needOffset:YES];
    UInt8 count = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
    
    for(int i = 0; i < count; i++){
        
        FSBrokerBranchByStock *brachByStock = [[FSBrokerBranchByStock alloc]init];
        
        brachByStock.identCode = identCode;
        brachByStock.symbol = symbol;
        brachByStock.startDate = startDate;
        brachByStock.endDate = endDate;
        brachByStock.dealVolume = dealVolume;
        
        UInt8 *tmpTitle = tmpPtr;
        int dataLength = [CodingUtil getUInt8:&tmpTitle needOffset:YES];
        
        brachByStock.brokerBranchData = [[BrokerBranchFormat1 alloc]initWithByte:&tmpTitle needOffset:YES];
        [brokerBranchStock addObject:brachByStock];
        
        tmpPtr += dataLength + 1;
        
    }
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    if([model.mainBargaining respondsToSelector:@selector(mainBargainingChipCallBack:)]) {
        [model.mainBargaining performSelector:@selector(mainBargainingChipCallBack:) onThread:model.thread withObject:brokerBranchStock waitUntilDone:NO];
    }
                        
}

@end

@implementation FSBrokerBranchByAnchorIn

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{
        
    NSMutableArray *brokerBranchAnchor = [[NSMutableArray alloc]init];
    
    UInt8 *tmpPtr = body;
    
    UInt16 identCode = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    NSString *symbol = [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
    NSString *brokerBranchId = [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
    UInt16 count = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    
    for(int i = 0; i < count; i++){
        
        FSBrokerBranchByAnchor *brachByAnchor = [[FSBrokerBranchByAnchor alloc]init];
        
        brachByAnchor.identCode = identCode;
        brachByAnchor.symbol = symbol;
        brachByAnchor.brokerBranchId = brokerBranchId;
        
        UInt8 *tmpTitle = tmpPtr;
        int dataLength = [CodingUtil getUInt8:&tmpTitle needOffset:YES];
        
        brachByAnchor.brokerBranchData = [[BrokerBranchFormat3 alloc]initWithByte:&tmpTitle needOffset:YES];
        [brokerBranchAnchor addObject:brachByAnchor];
        
        tmpPtr += dataLength + 1;
        
    }
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    if([model.mainBargaining respondsToSelector:@selector(mainBargainingChipCallBack:)]) {
        [model.mainBargaining performSelector:@selector(mainBargainingChipCallBack:) onThread:model.thread withObject:brokerBranchAnchor waitUntilDone:NO];
    }

}

@end

@implementation FSBrokerBranchDetailByAnchorIn

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{
    
    NSMutableArray *brokerBranchDetailAnchor = [[NSMutableArray alloc]init];
    
    UInt8 *tmpPtr = body;
    
    UInt16 identCode = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    NSString *symbol = [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
    UInt16 dataDate = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    NSString *brokerBranchId = [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
    FSBValueFormat *dealVolume = [[FSBValueFormat alloc]initWithByte:&tmpPtr needOffset:YES];
    UInt16 count = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    
    for(int i = 0; i < count; i++){
        
        FSBrokerBranchDetailByAnchor *branchDetailByAnchor = [[FSBrokerBranchDetailByAnchor alloc]init];
        
        branchDetailByAnchor.identCode = identCode;
        branchDetailByAnchor.symbol = symbol;
        branchDetailByAnchor.dataDate = dataDate;
        branchDetailByAnchor.brokerBranchId = brokerBranchId;
        branchDetailByAnchor.dealVolume = dealVolume;
        
//        UInt8 *tmpTitle = tmpPtr;
//        int dataLength = [CodingUtil getUInt8:&tmpTitle needOffset:YES];
        
        branchDetailByAnchor.brokerBranchData = [[BrokerBranchFormat4 alloc]initWithByte:&tmpPtr needOffset:YES];
        [brokerBranchDetailAnchor addObject:branchDetailByAnchor];
        
//        tmpPtr += dataLength + 1;
        
    }
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    if([model.mainBargaining respondsToSelector:@selector(mainBargainingChipCallBack:)]) {
        [model.mainBargaining performSelector:@selector(mainBargainingChipCallBack:) onThread:model.thread withObject:brokerBranchDetailAnchor waitUntilDone:NO];
    }
    
}

@end

@implementation FSBrokerBranchByBrokerIn

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{
    
    NSMutableArray *brokerBranchByBroker = [[NSMutableArray alloc]init];
    
    UInt8 *tmpPtr = body;
    
    UInt16 startDate = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    UInt16 endDate = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    NSString *brokerBranchId = [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
    UInt8 count = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
    
    for(int i = 0; i < count; i++){
        
        FSBrokerBranchByBroker *branchByBroker = [[FSBrokerBranchByBroker alloc]init];
        
        branchByBroker.startDate = startDate;
        branchByBroker.endDate = endDate;
        branchByBroker.brokerBranchId = brokerBranchId;
        
        UInt8 *tmpTitle = tmpPtr;
        int dataLength = [CodingUtil getUInt8:&tmpTitle needOffset:YES];
        
        branchByBroker.brokerBranchData = [[BrokerBranchFormat2 alloc]initWithByte:&tmpTitle needOffset:YES];
        [brokerBranchByBroker addObject:branchByBroker];
        
        tmpPtr += dataLength + 1;
        
    }
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    if([model.mainBargaining respondsToSelector:@selector(mainBargainingChipCallBack:)]) {
        [model.mainBargaining performSelector:@selector(mainBargainingChipCallBack:) onThread:model.thread withObject:brokerBranchByBroker waitUntilDone:NO];
    }
    
}

@end

@implementation FSMainBranchKLineIn
double offsetShareTotal;

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{
    
    NSMutableArray *brokerBranchKLine = [[NSMutableArray alloc]init];
    NSMutableArray *brokerBranchKLineShareTotal = [[NSMutableArray alloc]init];
//    NSMutableArray *brokerBranchKLineData = [[NSMutableArray alloc]init];

    UInt8 *tmpPtr = body;
    
    UInt8 brokerBranchIdCount;
    UInt16 identCode = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    NSString *symbol = [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
    brokerBranchIdCount = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
    NSString *brokerBranchId = [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
    UInt8 dataType = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
    UInt16 count = [CodingUtil getUInt16:&tmpPtr needOffset:YES];

//    FSMainBranchKLine *branchKLine;
//    接資料從是從今日到起始日，累積算法要從起始日開始加總，所以要再跑一次顛倒迴圈
    for(int i = 0; i < count; i++){
        
        FSMainBranchKLine *branchKLine = [[FSMainBranchKLine alloc]init];
        
        branchKLine.identCode = identCode;
        branchKLine.symbol = symbol;
        branchKLine.brokerBranchId = brokerBranchId;
        
        UInt8 *tmpTitle = tmpPtr;
        int dataLength = [CodingUtil getUInt8:&tmpTitle needOffset:YES];
        
        if (dataType == 0) {
            branchKLine.brokerBranchData5 = [[BrokerBranchFormat5 alloc]initWithByte:&tmpTitle needOffset:YES];
//            買賣超總和
//            offsetShareTotal += branchKLine.brokerBranchData5.offsetShare.calcValue;
        }else{
            branchKLine.brokerBranchData6 = [[BrokerBranchFormat6 alloc]initWithByte:&tmpTitle needOffset:YES];
        }
//        branchKLine.offsetShareTotal = offsetShareTotal / 1000;
        [brokerBranchKLine addObject:branchKLine];

        tmpPtr += dataLength + 1;
    }
//    將資料從起始到今日，累積才能符合每日買賣超
    for(NSUInteger i = [brokerBranchKLine count] - 1; i > -1; i--){
        FSMainBranchKLineNew *newInfo = [[FSMainBranchKLineNew alloc]init];
        FSMainBranchKLine *info = [brokerBranchKLine objectAtIndex:i];
//            買賣超總和
        double tt = info.brokerBranchData5.offsetShare.calcValue;
        offsetShareTotal += tt;
        newInfo.identCode = info.identCode;
        newInfo.symbol = info.symbol;
        newInfo.brokerBranchId = info.brokerBranchId;
        newInfo.brokerBranchData5 = info.brokerBranchData5;
        newInfo.offsetShareTotal = offsetShareTotal / 1000;

        [brokerBranchKLineShareTotal addObject:newInfo];
    }
//    [brokerBranchKLineData addObject:brokerBranchKLine];
//    [brokerBranchKLineData addObject:brokerBranchKLineShareTotal];
    
//    FSDataModelProc *model = [FSDataModelProc sharedInstance];
//    if([model.mainBargaining respondsToSelector:@selector(mainBargainingChipCallBack:)]) {
//        [model.mainBargaining performSelector:@selector(mainBargainingChipCallBack:) onThread:model.thread withObject:brokerBranchKLineShareTotal waitUntilDone:NO];
//    }
    
}

@end

@implementation FSOptionalMainIn

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{
    NSMutableArray *optionalMain = [[NSMutableArray alloc]init];
    
    UInt8 *tmpPtr = body;
    
    UInt16 startDate = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    UInt16 endDate = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    UInt8 idCount = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
    NSString *brokerBranchId;
    
    for (int i = 0; i < idCount; i ++){
        brokerBranchId = [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
    }
    
    UInt8 count = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
    
    for(int i = 0; i < count; i++){
        
        FSBrokerOptional *optionalMainInfo = [[FSBrokerOptional alloc]init];
        
        optionalMainInfo.startDate = startDate;
        optionalMainInfo.endDate = endDate;
        optionalMainInfo.idCount = idCount;
        
        UInt8 *tmpTitle = tmpPtr;
        int dataLength = [CodingUtil getUInt8:&tmpTitle needOffset:YES];
        
        optionalMainInfo.brokerBranchData = [[BrokerBranchFormat2 alloc]initWithByte:&tmpTitle needOffset:YES];
        [optionalMain addObject:optionalMainInfo];
        
        tmpPtr += dataLength + 1;
    }
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    if([model.mainBargaining respondsToSelector:@selector(mainBargainingChipCallBack:)]) {
        [model.mainBargaining performSelector:@selector(mainBargainingChipCallBack:) onThread:model.thread withObject:optionalMain waitUntilDone:NO];
    }
    
}

@end

@implementation BrokerBranchFormat1
@synthesize brokerBranchID, buyShare, sellShare, buyPrice, sellPrice;

-(instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset{
    if (self = [super init]) {
        UInt8 *ptr = *sptr;
        
        brokerBranchID = [CodingUtil getShortStringFormatByBuffer:&ptr needOffset:needOffset];
        buyShare = [[FSBValueFormat alloc]initWithByte:&ptr needOffset:needOffset];
        sellShare = [[FSBValueFormat alloc]initWithByte:&ptr needOffset:needOffset];
        buyPrice = [[FSBValueFormat alloc]initWithByte:&ptr needOffset:needOffset];
        sellPrice = [[FSBValueFormat alloc]initWithByte:&ptr needOffset:needOffset];
        
        *sptr = ptr;
    }
    return self;
}

@end

@implementation BrokerBranchFormat2
@synthesize symbolFormat1, buyAmount, sellAmount, dealAmount, buyPrice, sellPrice;

-(instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset{
    if (self = [super init]) {
        UInt8 *ptr = *sptr;
        
        UInt16 tmpSize= 0;
        symbolFormat1 = [[SymbolFormat1 alloc] initWithBuff:ptr objSize:&tmpSize Offset:0];
        *sptr += tmpSize;
        
        buyAmount = [[FSBValueFormat alloc]initWithByte:sptr needOffset:needOffset];
        sellAmount = [[FSBValueFormat alloc]initWithByte:sptr needOffset:needOffset];
        dealAmount = [[FSBValueFormat alloc]initWithByte:sptr needOffset:needOffset];
        buyPrice = [[FSBValueFormat alloc]initWithByte:sptr needOffset:needOffset];
        sellPrice = [[FSBValueFormat alloc]initWithByte:sptr needOffset:needOffset];
        
        *sptr = ptr;
    }
    return self;
}

@end

@implementation BrokerBranchFormat3
@synthesize dataDate, buyShare, sellShare, dealShare, buyPrice, sellPrice;

-(instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset{
    if (self = [super init]) {
        UInt8 *ptr = *sptr;
        
        dataDate = [CodingUtil getUInt16:&ptr needOffset:needOffset];
        buyShare = [[FSBValueFormat alloc]initWithByte:&ptr needOffset:needOffset];
        sellShare = [[FSBValueFormat alloc]initWithByte:&ptr needOffset:needOffset];
        dealShare = [[FSBValueFormat alloc]initWithByte:&ptr needOffset:needOffset];
        buyPrice = [[FSBValueFormat alloc]initWithByte:&ptr needOffset:needOffset];
        sellPrice = [[FSBValueFormat alloc]initWithByte:&ptr needOffset:needOffset];
        
        *sptr = ptr;
    }
    return self;
}
@end

@implementation BrokerBranchFormat4
@synthesize buyShare, sellShare, dealShare;

-(instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset{
    if (self = [super init]) {
        UInt8 *ptr = *sptr;
        
        dealShare = [[FSBValueFormat alloc]initWithByte:&ptr needOffset:needOffset];
        buyShare = [[FSBValueFormat alloc]initWithByte:&ptr needOffset:needOffset];
        sellShare = [[FSBValueFormat alloc]initWithByte:&ptr needOffset:needOffset];
        
        *sptr = ptr;
    }
    return self;
}
@end

@implementation BrokerBranchFormat5
@synthesize dataDate, offsetShare;

-(instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset{
    if (self = [super init]) {
        UInt8 *ptr = *sptr;
        
        dataDate = [CodingUtil getUInt16:&ptr needOffset:needOffset];
        offsetShare = [[FSBValueFormat alloc]initWithByte:&ptr needOffset:needOffset];

        *sptr = ptr;
    }
    return self;
}
@end

@implementation BrokerBranchFormat6
@synthesize dataDate, buyShare, sellShare, buyAmnt, sellAmnt;

-(instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset{
    if (self = [super init]) {
        UInt8 *ptr = *sptr;
        
        dataDate = [CodingUtil getUInt16:&ptr needOffset:needOffset];
        buyShare = [[FSBValueFormat alloc]initWithByte:&ptr needOffset:needOffset];
        sellShare = [[FSBValueFormat alloc]initWithByte:&ptr needOffset:needOffset];
        buyAmnt = [[FSBValueFormat alloc]initWithByte:&ptr needOffset:needOffset];
        sellAmnt = [[FSBValueFormat alloc]initWithByte:&ptr needOffset:needOffset];
        
        *sptr = ptr;
    }
    return self;
}
@end
