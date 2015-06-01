//
//  EsmTraderSyncIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/6/17.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"


@interface EsmTraderSyncIn : NSObject <DecodeProtocol>{
	NSMutableArray *traderAddArray;
	NSMutableArray *traderRemoveArray;
@public
	UInt8 returnCode;
	UInt16 recordDate;
}

@property (readonly) NSMutableArray *traderAddArray;
@property (readonly) NSMutableArray *traderRemoveArray;

@end



@interface EsmTraderParam : NSObject
{
	NSString *traderName;
	NSString *traderTele;
@public
	UInt16 traderID;
}

@property (nonatomic,copy) NSString *traderName;
@property (nonatomic,copy) NSString *traderTele;

@end
