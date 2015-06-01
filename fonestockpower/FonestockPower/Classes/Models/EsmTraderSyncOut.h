//
//  EsmTraderSyncOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/6/17.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"


@interface EsmTraderSyncOut : NSObject <EncodeProtocol>{
	UInt16 recordDate;
}

- (id)initWithRecordDate:(UInt16)rd;

@end
