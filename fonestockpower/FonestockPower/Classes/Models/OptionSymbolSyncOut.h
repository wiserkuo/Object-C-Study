//
//  OptionSymbolSyncOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/3/27.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"

@interface OptionSymbolSyncOut : NSObject <EncodeProtocol>{
	UInt16 sectorID;
	UInt16 date;
}

- (id)initWithSectorID:(UInt16)sID Date:(UInt16)d;

@end
