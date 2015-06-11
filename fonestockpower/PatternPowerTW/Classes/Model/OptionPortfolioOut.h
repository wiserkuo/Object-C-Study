//
//  OptionPortfolioOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/2/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodingUtil.h"
#import "EncodeProtocol.h"


@interface OptionPortfolioOut : NSObject <EncodeProtocol>{
	UInt8 count;   //count of symbol
	UInt8 identCode[2];
	NSArray *symbolArray;
	UInt8 year;	   //since 1960 
	UInt8 month;
	UInt8 callPut; //0:call, 1:put 
	UInt8 action;  //1 to add, 0 to delete 
}

@property (nonatomic,retain) NSArray *symbolArray;

- (id)initWithCallIndetCode:(char*)ic SymbolArray:(NSArray*)sa Year:(UInt16)y Month:(UInt8)m Action:(UInt8)ac;
- (id)initWithPutIndetCode:(char*)ic SymbolArray:(NSArray*)sa Year:(UInt16)y Month:(UInt8)m Action:(UInt8)ac;

@end
