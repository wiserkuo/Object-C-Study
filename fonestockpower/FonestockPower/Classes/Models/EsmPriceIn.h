//
//  EsmPriceIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/6/19.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@class EsmPriceParam;
@interface EsmPriceIn : NSObject <DecodeProtocol>{
	EsmPriceParam *esmPriceParam;
@public
	UInt8 returnCode;
	UInt8 dataLength;		//不知道幹啥用 資料長度( 長度為0,無EsmPriceParam
}

@property (readonly) EsmPriceParam *esmPriceParam;

@end
