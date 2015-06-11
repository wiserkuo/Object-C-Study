//
//  FSSymbolKeywordIn.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/4/29.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@interface FSSymbolKeywordIn : NSObject<DecodeProtocol>{
    NSString *keyword;
    NSMutableArray *dataArray;
@public
    UInt8 fieldType;
    UInt8 searchType;
    UInt8 lengthKeyword;
    UInt8 numSymbol;
    UInt16 sectorID;
    UInt8 flag;
    UInt16 totalNumber;
    UInt8 retCode;
}

@property (nonatomic,readonly) NSString *keyword;
@property (nonatomic,readonly) NSMutableArray *dataArray;

@end