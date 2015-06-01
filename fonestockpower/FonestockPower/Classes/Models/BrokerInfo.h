//
//  BrokerInfo.h
//  Bullseye
//
//  Created by steven on 2009/6/16.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BrokersIn.h"


@protocol BrokerNotifyProtocol <NSObject>

-(void)notify;

@end

@interface BrokerName : NSObject {
@public
	UInt8   Type;
	UInt16  BrokerID;
	NSString *fullName;
}
@property (nonatomic,copy) NSString *fullName;

@end


@interface BrokerInfo : NSObject{
	NSMutableArray  *dataCacheArray;	
	NSObject <BrokerNotifyProtocol>  *notifyTarget;
	NSRecursiveLock *lock;
}

- (void) initDatabase;
- (void) reloadData;
- (void) setTarget: (NSObject <BrokerNotifyProtocol>*) obj;
- (void) syncBrokerInfo:(BrokersIn *) obj;

- (int) getCount;
- (BrokerName*) getItemAt: (int) position;
- (NSString*) getNameAt: (int) position;
- (NSString*) getNameByID: (UInt16) brokerID;

@end
