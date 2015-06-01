//
//  EquityNotification.h
//  Bullseye
//
//  Created by johaiyu on 2009/2/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotifyAgent.h"

/*
	This object keeps the required information to inform the target of incoming ticks.
	It must implement isEqual and hash methods to be used in collection.
 */
@interface EquityNotificationEntity : NSObject
{
	NSObject *notifiyTarget;
	NSThread *targetThread;
}

@property (nonatomic, readonly) NSObject *notifiyTarget;
@property (nonatomic, readonly) NSThread *targetThread;

- (id)initWithTarget:(NSObject *)target Thread:(NSThread *)thread;

@end


@interface EquityNotification :  NotifyAgent
{
}

- (void)notifyTarget:(NSObject *)keyCommodityNo WithEquityDictionary:(NSDictionary *)dic IncludeAll:(BOOL)include;
- (void)fromOldKey:(NSObject *)oldKey ToNewKey:(NSObject *)newKey;
- (void)removefromKey:(NSObject *)oldKey;
- (void)removeEntityForAll:(NSObject *)entity;
@end
