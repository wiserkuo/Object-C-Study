//
//  PortfolioOut.h
//  Bullseye
//
//  Created by Yehsam on 2008/11/25.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EncodeProtocol.h"



@interface PortfolioOut : NSObject <EncodeProtocol>{
	UInt8 subType;
	UInt8 count;
	int allSize;
	UInt8 *allIdenSymbol;
	UInt32 *allSercurityNos;
	NSMutableArray *commodities;
	NSMutableArray *securityNos;
}

- (void)addPortfolio:(NSMutableArray*)s;
- (void)removePortfolio:(UInt32*)s count:(UInt8)c;
- (void)addWatchLists:(NSMutableArray*)s;
- (void)removeWatchLists:(UInt32*)s count:(UInt8)c;
- (void)addFocusd:(UInt32)s;
- (void)removeFocusd;


@end
