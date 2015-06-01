//
//  MessageType14.h
//  Bullseye
//
//  Created by Yehsam on 2009/2/18.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@class TargetPriceParam;
@interface MessageType14 : NSObject <DecodeProtocol>{
	TargetPriceParam *tpParam;
}

@end

@interface TargetPriceParam : NSObject {
@public
	UInt16 targetPriceTime;
	double targetPrice;
	double targetRefPrice;
}

@end
