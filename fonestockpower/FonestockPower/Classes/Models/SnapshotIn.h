//
//  SnapshotIn.h
//  FonestockPower
//
//  Created by Connor on 14/4/23.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Snapshot.h"

@interface SnapshotIn : NSObject <DecodeProtocol>{
	UInt8 dataLength;
	SnapshotParam *ssParam;
}




@end
