//
//  PortfolioIn.h
//  Bullseye
//
//  Created by Yehsam on 2008/11/25.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecodeProtocol.h"



@interface PortfolioIn : NSObject <DecodeProtocol>{
	UInt8 subType;
	UInt8 block1Count;
	UInt8 block2Count;
	NSMutableArray *Block1dataArray;
	NSMutableArray *Block2dataArray;
@public
	UInt8 returnCode;
}

@property (nonatomic,strong) NSMutableArray *Block1dataArray;
@property (nonatomic,strong) NSMutableArray *Block2dataArray;

@end

@interface Block1 : NSObject{
@public
	UInt8 marketID;
	char Ident_Code[2];
	UInt8 symbolLength;
	NSString *symbol;
	UInt32 sercurity1Num;	
}

@end

@interface Block2 : NSObject{
@public
	UInt32 sercurity2Num;
	UInt32 TargetNum;
}

@end
