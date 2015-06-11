//
//  TickDataOut.h
//  Bullseye
//
//  Created by Yehsam on 2008/12/4.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EncodeProtocol.h"


@interface TickDataOut : NSObject <EncodeProtocol>{
	UInt32 commodityNum;
	UInt16 beginSN;
	UInt16 endSN;
}

- (id)initWithCommodityNum:(UInt32)c BeginSN:(UInt16)bSN EndSN:(UInt16)eSN;

@end
