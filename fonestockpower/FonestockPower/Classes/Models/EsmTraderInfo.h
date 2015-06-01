//
//  EsmTraderInfo.h
//  Bullseye
//
//  Created by steven on 2009/6/19.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EsmTraderSyncIn.h"
#import "FSCategoryTree.h"


@protocol EsmTraderNotifyProtocol <NSObject>

-(void)notify;

@end

@interface EsmTraderInfo : NSObject {
	NSMutableArray  *dataCacheArray;	
	NSObject <EsmTraderNotifyProtocol>  *notifyTarget;
	NSRecursiveLock *lock;
}

- (void) initDatabase;
- (void) reloadData;
- (void) setTarget: (NSObject <EsmTraderNotifyProtocol>*) obj;
- (void) syncEsmTraderInfo:(EsmTraderSyncIn *) obj;

- (int) getCount;
- (EsmTraderParam*) getItemAt: (int) position;
- (NSString*) getNameAt: (int) position;
- (NSString*) getNameByID: (UInt16) traderID;
- (NSString*) getPhoneByID: (UInt16) traderID;

@end
