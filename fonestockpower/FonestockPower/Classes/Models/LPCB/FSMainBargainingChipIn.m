//
//  FSMainBargainingChipIn.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSMainBargainingChipIn.h"
#import "FSMainBargainingModel.h"

@implementation FSMainBargainingChipIn

-(id)init{
    if(self = [super init]){
        mainBargainingChipArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{
    
    UInt8 *tmpPtr = body;
    
    UInt16 startDate = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    UInt16 endDate = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    UInt8 dataType = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
    UInt8 count = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
    
    for(int i = 0; i < count; i++ ){

        FSMainBargainingChip *mainBargainingChip = [[FSMainBargainingChip alloc]init];

        mainBargainingChip.startDate = startDate;
        mainBargainingChip.endDate = endDate;
        mainBargainingChip.dataType = dataType;
        
        UInt8 *tmpTitle = tmpPtr;
        int dataLength = [CodingUtil getUInt8:&tmpTitle needOffset:YES];
        
        UInt16 tmpSize = 0;
        mainBargainingChip.symbol = [[SymbolFormat1 alloc]initWithBuff:tmpTitle objSize:&tmpSize Offset:0];
        tmpTitle += tmpSize;
        
        mainBargainingChip.buyShare = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
        mainBargainingChip.sellShare = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
        mainBargainingChip.avgPrice = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
        mainBargainingChip.changePercentage = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
        mainBargainingChip.avgVolume = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
        mainBargainingChip.buyAvgPrice = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
        mainBargainingChip.sellAvgPrice = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
        mainBargainingChip.data = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];

        [mainBargainingChipArray addObject:mainBargainingChip];
        
        tmpPtr += dataLength + 1;
    }
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    if([model.mainBargaining respondsToSelector:@selector(mainBargainingChipCallBack:)]) {
        [model.mainBargaining performSelector:@selector(mainBargainingChipCallBack:) onThread:model.thread withObject:mainBargainingChipArray waitUntilDone:NO];
    }
}

@end
