//
//  MessageType21.h
//  Bullseye
//
//  Created by Yehsam on 2009/11/2.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@class AlertPushParam;
@interface MessageType21 : NSObject <DecodeProtocol>{
	AlertPushParam *apParam;
@public
	UInt8 retCode;
}

@property (nonatomic,readonly) AlertPushParam *apParam;

@end


@interface AlertPushParam : NSObject
{
@public
	UInt32 securityNum;
	UInt16 tickTime;
	double dealValue;		//使發生alert的tick的成交價(絕對價)
	UInt8 dealValueUnit;
	double dealVolume;		//使發生alert的tick的單量
	UInt8 dealVolumeUnit;
	UInt8 alertIDCount;		//alert id 重複次數
	UInt8 *alertID;			//達到alert條件的alert id
	UInt8 *alertType;		//1: 發生alert, 2: alert消失
}

@end
