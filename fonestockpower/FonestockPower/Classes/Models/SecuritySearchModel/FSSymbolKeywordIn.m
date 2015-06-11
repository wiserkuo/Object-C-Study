//
//  FSSymbolKeywordIn.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/4/29.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSSymbolKeywordIn.h"
#import "SecuritySearchModel.h"
#import "NewSymbolKeywordIn.h"

@implementation FSSymbolKeywordIn

@synthesize keyword;
@synthesize dataArray;

- (id)init
{
    if(self = [super init])
    {
        dataArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
    
    UInt8 *tmpPtr = body;
    fieldType = [CodingUtil getUint8FromBuf:tmpPtr Offset:0 Bits:4];
    searchType = [CodingUtil getUint8FromBuf:tmpPtr Offset:4 Bits:4];
    tmpPtr++;
    lengthKeyword = *tmpPtr++;
    keyword = [[NSString alloc] initWithBytes:tmpPtr length:lengthKeyword encoding:NSUTF8StringEncoding];
    tmpPtr += lengthKeyword;
    numSymbol = *tmpPtr++;
    retCode = retcode;
    NSLog(@"FSSymbolKeywordIn count:%d retCode:%d",numSymbol,retCode);
    
    if(numSymbol)
    {
        for(int i=0 ; i<numSymbol ; i++)
        {
            NumberOfSymbol *NOS = [[NumberOfSymbol alloc] init];
            UInt16 tmpSize=0;
            NOS->data = [[SymbolFormat1 alloc] initWithBuff:tmpPtr objSize:&tmpSize Offset:0];
            tmpPtr += tmpSize;
//            NSLog(@"FSSymbolKeywordIn IdentCode:%c%c fullName:%@",NOS->data->IdentCode[0], NOS->data->IdentCode[1],NOS->data->fullName);
            if (NOS -> data) {
                NSString *identCode = [NSString stringWithFormat:@"%c%c", NOS -> data -> IdentCode[0], NOS -> data -> IdentCode[1]];
                if ([identCode isEqualToString:@"SS"]) {
                    NOS -> sectorID = 101;
                }else{
                    NOS -> sectorID = 121;
                }
            }
            [dataArray addObject:NOS];
        }
        flag = *tmpPtr++;
        if(flag){
            totalNumber = [CodingUtil getUInt16:tmpPtr];
        }
    }
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel performSelector:@selector(searchAgain:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}


@end


