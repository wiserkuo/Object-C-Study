//
//  AlertSnapshotIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/11/2.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@interface AlertSnapshotIn : NSObject <DecodeProtocol>{
	NSMutableArray *alertSnapshotArray;
@public
	UInt8 retCode;
}

@property (nonatomic,readonly) NSMutableArray *alertSnapshotArray;

@end


@interface AlertSnapshotParam : NSObject
{
@public
	UInt32 securityNum;
	UInt16 tickTime;
	double dealValue;		//目前的成交價(絕對價)
	UInt8 dealValueUnit;
	double dealVolume;		//目前的成交量(單量)
	UInt8 dealVolumeUnit;
	UInt8 alertBytesCount;
	UInt8 *alertBytes;		//達到alert條件的alert id, 以bit來表示alert id的on off, 1st bit --> alert 1
}


@end
