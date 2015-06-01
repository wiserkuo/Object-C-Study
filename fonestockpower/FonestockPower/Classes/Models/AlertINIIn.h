//
//  AlertINIIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/11/18.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@interface AlertINIIn : NSObject <DecodeProtocol>{
@public
	UInt16 date;
	UInt8 sn;		//Serial number of packets. 由1開始
	UInt8 totalSN;	//表示被切成多少個packets.
	UInt16 dataLength;
	UInt8 *data;
	UInt8 returnCode;
}

@end
