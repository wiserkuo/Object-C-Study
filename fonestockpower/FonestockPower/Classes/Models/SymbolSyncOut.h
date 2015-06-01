//
//  SymbolSyncOut.h
//  Bullseye
//
//  Created by Yehsam on 2008/12/3.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EncodeProtocol.h"


@interface SymbolSyncOut : NSObject <EncodeProtocol>{
	UInt16 sectorID;
	UInt16 date;
}

- (id)initWithSectorID:(UInt16)sID year:(UInt16)y month:(UInt8)m day:(UInt8)d;
- (id)initWithSectorID_SyncDate:(UInt16)sID syncDate:(UInt16) syncDate;

@end
