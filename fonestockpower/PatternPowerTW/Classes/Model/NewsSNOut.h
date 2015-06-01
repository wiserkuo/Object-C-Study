//
//  NewSNOut.h
//  Bullseye
//
//  Created by Yehsam on 2008/11/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EncodeProtocol.h"


@interface NewsSNOut : NSObject <EncodeProtocol>{
	UInt8 count;
	UInt16 *newsSectorRootID;
}

- (id)initWithNewsSectorID:(UInt16*)sID count:(UInt8)c;


@end
