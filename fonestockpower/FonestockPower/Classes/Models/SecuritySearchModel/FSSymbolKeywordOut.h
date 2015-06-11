//
//  FSSymbolKeywordOut.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/4/29.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"

@interface FSSymbolKeywordOut : NSObject<EncodeProtocol>{
    UInt8 count;
    UInt8 pageNo;
    UInt8 fieldType;
    UInt8 searchType;
    UInt8 length;
    NSString *keyword;
    
}

-(id)initWithCountPage:(UInt8)cP PageNo:(UInt8)pN FieldType:(UInt8)fT SearchType:(UInt8)sT;
-(void)setKeyword:(NSString*)k;

@end
