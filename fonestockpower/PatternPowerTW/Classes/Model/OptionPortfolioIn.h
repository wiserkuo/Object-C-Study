//
//  OptionPortfolioIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/2/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@interface OptionPortfolioIn : NSObject <DecodeProtocol>{
	NSMutableArray *optionPortfolioArray;
}

@property (nonatomic,retain) NSMutableArray *optionPortfolioArray;

@end



@interface OptionPortfolioParam : NSObject{
@public
	UInt8 marketID;
	UInt8 identCode[2];
	NSString *symbol;
	UInt16 year;  //已加上1960
	UInt8 month;
	UInt8 callPut; //0:call, 1:put 
	UInt32 targetSecurityNum;
	NSMutableArray *strikePriceArray;
}

@property (nonatomic,copy) NSString *symbol;
@property (nonatomic,retain) NSMutableArray *strikePriceArray;

@end

@interface StrikePriceParam : NSObject {
@public
	UInt8 exponent;
	UInt32 strikePrice;
	UInt32 sn;
}

@end

