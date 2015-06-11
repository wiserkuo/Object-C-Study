//
//  AlertSnapshotOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/11/2.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"

@interface AlertSnapshotOut : NSObject <EncodeProtocol>{
	UInt32 *securityNum;
	UInt16 count;
}

- (id)initWithSecurityNum:(UInt32*)sNum Count:(UInt16)c;

@end
