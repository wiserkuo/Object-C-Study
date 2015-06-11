//
//  NewsTitleOut.h
//  Bullseye
//
//  Created by Yehsam on 2008/11/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EncodeProtocol.h"

@interface NewsTitleOut : NSObject <EncodeProtocol>{
	UInt16 sectorID;
	UInt16 beginSN;
	UInt16 endSN;
}

- (id)initWithSectorID:(UInt16)sID BeginSN:(UInt16)bSN EndSN:(UInt16)eSN;

@end
