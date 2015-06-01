//
//  NewsContentOut.h
//  Bullseye
//
//  Created by Yehsam on 2008/11/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EncodeProtocol.h"

@interface NewsContentOut : NSObject <EncodeProtocol>{
	UInt8 type;
	// type0
	UInt32 newsSN;
	// type1
	UInt16 date;
	UInt16 sectorID;
	UInt16 SN;
	
}

- (id)initWithType0SN:(UInt32)newSN;
- (id)initWithType1Date:(UInt16)d sectorID:(UInt16)sID SN:(UInt16)s;

@end
