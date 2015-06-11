//
//  EsmPriceOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/6/19.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"


@interface EsmPriceOut : NSObject <EncodeProtocol>{
	UInt32 commodityNum;
}

- (id)initWithCommodityNum:(UInt32)cn;

@end
