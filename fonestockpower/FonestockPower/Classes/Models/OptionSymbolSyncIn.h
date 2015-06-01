//
//  OptionSymbolSyncIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/3/27.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@interface OptionSymbolSyncIn : NSObject <DecodeProtocol>{
@public
	UInt16 date;
	UInt8 syncType;	//0: add , 1: remove 
	UInt16 sectorID;
	UInt16 numberOfSymbol;
	NSMutableArray *dataArray;
	UInt8 retCode;	
}

@property (nonatomic,retain) NSMutableArray *dataArray;

@end
