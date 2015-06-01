//
//  FutrueOptionTargetPriceIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/2/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"


@interface FutrueOptionTargetPriceIn : NSObject <DecodeProtocol>{
@public
	BOOL checkType;
	UInt16 targetPriceTime;
	double targetPrice;
	double targetRefPrice;
	UInt8 targetPriceUnit;
}

@end
