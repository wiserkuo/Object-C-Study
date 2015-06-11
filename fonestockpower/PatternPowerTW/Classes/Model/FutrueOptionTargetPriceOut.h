//
//  FutrueOptionTargetPriceOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/2/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"


@interface FutrueOptionTargetPriceOut : NSObject <EncodeProtocol>{
	UInt8 count;
	UInt32 *targetNumber;
}

- (id)initWithTargetNumbers:(UInt32*)tn Counts:(UInt8)c;

@end
