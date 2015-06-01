//
//  AlertRegisterOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/11/2.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"


@interface AlertRegisterOut : NSObject <EncodeProtocol>{
	BOOL alertFlag;
}

- (id)initWithAlertFlag:(BOOL)onOff;
   
@end
