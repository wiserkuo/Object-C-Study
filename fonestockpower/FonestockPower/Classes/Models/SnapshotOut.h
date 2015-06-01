//
//  SnapshotOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/5/22.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"

@interface SnapshotOut : NSObject <EncodeProtocol>{
	UInt8 count;
	UInt8 subType[5];
	UInt32 commodityNum[5];
}

- (id) initWithSubType:(UInt8)st CommodityNum:(UInt32)cn;
- (void) addWithSubType:(UInt8)st CommodityNum:(UInt32)cn;

@end
