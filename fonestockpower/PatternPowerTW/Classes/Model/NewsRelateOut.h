//
//  NewsRelateOut.h
//  Bullseye
//
//  Created by Yehsam on 2008/11/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EncodeProtocol.h"

@interface NewsRelateOut : NSObject <EncodeProtocol>{
	UInt32 securitySN;
	UInt16 startDate;
	UInt16 endDate;
	UInt16 countPage;
	UInt8 pageNo;
}

- (id)initWithSecuritySN:(UInt32)s StarDate:(UInt16)sd EndDate:(UInt16)ed CountPage:(UInt8)c PageNo:(UInt8)p;

@end
