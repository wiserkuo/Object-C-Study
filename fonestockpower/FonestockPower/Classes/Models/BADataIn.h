//
//  BADataIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/2/11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@interface BADataIn : NSObject <DecodeProtocol>{
	UInt32 securityNO;
	NSMutableArray *BAArray;
}

@property (nonatomic,strong) NSMutableArray *BAArray;
@property (nonatomic,readonly) UInt32 securityNO;

@end


@interface BADataParam : NSObject{
@public
	UInt32 bidPrice;	//相對於reference
	UInt32 bidVolume;
	UInt32 askPrice;	//相對於reference
	UInt32 askVolume;
}

@end
