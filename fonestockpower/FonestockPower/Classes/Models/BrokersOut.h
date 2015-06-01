//
//  BrokersOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/1/8.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"


@interface BrokersOut : NSObject <EncodeProtocol>{
	UInt16 recordDate;
}

- (id)initWithRecordDate:(UInt16)rd;

@end
