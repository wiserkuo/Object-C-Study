//
//  MarketInfoOut.h
//  Bullseye
//
//  Created by Yehsam on 2008/11/24.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EncodeProtocol.h"


@interface MarketInfoOut : NSObject <EncodeProtocol>{
	UInt16 MITdate;
}

- (id)initWithDate:(int)year month:(int)month day:(int)day;

@end
