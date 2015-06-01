//
//  GetINIOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/11/18.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"

@interface GetINIOut : NSObject <EncodeProtocol>{
	UInt8 alertStockFlag;		//1是要Alert 0是Stock
	UInt16 date;		//前一次收到的DB資料日期
}

- (id)initWithDate:(UInt16)d SwitchINI:(UInt8)asFlag;

@end
