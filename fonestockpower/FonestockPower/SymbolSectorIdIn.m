//
//  SymbolSectorIdIn.m
//  FonestockPower
//
//  Created by Neil on 2014/10/28.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "SymbolSectorIdIn.h"

@implementation SymbolSectorIdIn

- (id)init
{
	if (self = [super init])
	{
	}
	
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
    NSMutableArray * sectorIdArray = [[NSMutableArray alloc]init];
	
	int count = *body++;
    for (int i =0; i<count; i++) {
        UInt16 sectorId = [CodingUtil getUInt16:body];
        body +=2;
        [sectorIdArray addObject:[NSNumber numberWithUnsignedInt:sectorId]];
    }
	
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
   [dataModel.category performSelector:@selector(dataCallBackWithArray:) onThread:dataModel.thread withObject:sectorIdArray waitUntilDone:NO];
	
}


@end
