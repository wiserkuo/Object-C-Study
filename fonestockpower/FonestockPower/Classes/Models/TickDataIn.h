//
//  TickDataIn.h
//  Bullseye
//
//  Created by Yehsam on 2008/12/4.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecodeProtocol.h"


@interface TickDataIn : NSObject <DecodeProtocol>{
	UInt16 dataCount;
	UInt8 messageType;
	UInt8 dataLength;
	NSMutableArray *dataArray;
}

@property (nonatomic,strong) NSMutableArray *dataArray;
@end

