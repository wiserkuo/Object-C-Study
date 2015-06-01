//
//  NewSymbolKeywordIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/11/6.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@interface NewSymbolKeywordIn : NSObject <DecodeProtocol>{
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

@interface NumberOfSymbol : NSObject{
@public
	SymbolFormat1 *data;
	UInt16 sectorID;		
}

@end
