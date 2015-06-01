//
//  BADataOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/2/11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"

@interface BADataOut : NSObject <EncodeProtocol>{
	UInt32 commodityNum;
}

- (id)initWithCommodityNum:(UInt32)cn;

@end
