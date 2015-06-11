//
//  EquityNotification.m
//  Bullseye
//
//  Created by johaiyu on 2009/2/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EquityNotification.h"

@implementation EquityNotificationEntity

@synthesize notifiyTarget;
@synthesize targetThread;


- (id)initWithTarget:(NSObject *)target Thread:(NSThread *)thread
{
	if (self = [super init])
	{
		notifiyTarget = target;
		targetThread = thread;
	}
	return self;
}

/*
	Use notification target to calculate the hash value.
 */
- (NSUInteger)hash
{
	return [notifiyTarget hash];
}

/*
	A target object was passed as the parameter.
	This is used to remove object from array.
 */
- (BOOL)isEqual:(id)anObject
{
	return [notifiyTarget isEqual:anObject];
}

@end


@implementation EquityNotification

#pragma mark Convert key between symbol and commodity number

- (void)fromOldKey:(NSObject *)oldKey ToNewKey:(NSNumber *)newKey
{
	[notifyLock lock];
	NSObject *waitQueue = [agentCounter objectForKey:oldKey];
	if (waitQueue)
	{
        [agentCounter setObject:waitQueue forKey:newKey];
        [agentCounter removeObjectForKey:oldKey];
	}
    
	[notifyLock unlock];
}

- (void)removefromKey:(NSObject *)oldKey
{
	[notifyLock lock];
	NSObject *waitQueue = [agentCounter objectForKey:oldKey];
	if (waitQueue)
	{
		[agentCounter removeObjectForKey:oldKey];
	}
	[notifyLock unlock];
}

#pragma mark Notification method

/**
	This method is used to notify all waiting entities the ticks had come.
	The input dictionary contains commodity number and equity ticks pairs.
 
	v1.1 add one option for including or excluding PortfolioAll from notification.
	For ticks before current time there is no need to include PortfolioAll as the target.
 */
- (void)notifyTarget:(NSObject *)keyCommodityNo WithEquityDictionary:(NSDictionary *)dic IncludeAll:(BOOL)include
{
	[notifyLock lock];
	NSArray *waitQueue = [self getTriggeredEntities:keyCommodityNo];
	if (waitQueue)
	{
		NSObject *equityObj = [dic objectForKey:keyCommodityNo];
		if (equityObj)
		{
			for (EquityNotificationEntity *target in waitQueue)
				[target.notifiyTarget performSelector:@selector(notifyDataArrive:) onThread:target.targetThread withObject:equityObj waitUntilDone:NO];
		}
	}
	
	// Check if someone is waiting for all kinds of ticks.
	if (include)
	{
        waitQueue = [self getTriggeredEntities:@"PortfolioAll"];
        if (waitQueue)
            for (EquityNotificationEntity *target in waitQueue)
                [target.notifiyTarget performSelector:@selector(notifyDataArrive:) onThread:target.targetThread withObject:nil waitUntilDone:NO];
	}
	
	[notifyLock unlock];
}

#pragma mark Overload parent's methods

/*
	Use EquityNotificationEntity for waiting entity.
 */
- (void)addKey:(NSObject *)key Entity:(NSObject *)entity
{
	EquityNotificationEntity *waitEntity = [[EquityNotificationEntity alloc] initWithTarget:entity Thread:[NSThread currentThread]];
	[super addKey:key Entity:waitEntity];
}

- (void)addEntityForAll:(NSObject *)entity
{
	EquityNotificationEntity *waitEntity = [[EquityNotificationEntity alloc] initWithTarget:entity Thread:[NSThread currentThread]];
	[super addEntityForAll:waitEntity];
}

- (void)removeKey:(NSObject *)key Entity:(NSObject *)entity
{
	NSMutableArray *waitQueue = [agentCounter objectForKey:key];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"notifiyTarget == %@ && targetThread == %@", entity, [NSThread currentThread]];
    NSArray *filteredArray = [waitQueue filteredArrayUsingPredicate:predicate];
    for (EquityNotificationEntity *entity in filteredArray) {
        [super removeKey:key Entity:entity];
    }
//    [waitQueue removeObjectsInArray:filteredArray];
}

- (void)removeEntityForAll:(NSObject *)entity
{
	[notifyLock lock];
	NSEnumerator *enumerator = [agentCounter keyEnumerator];
	id key = nil;
	NSMutableArray *dictRmoveKey = [[NSMutableArray alloc] init];
	while ((key = [enumerator nextObject])) {
		NSMutableArray *waitQueue = [agentCounter objectForKey:key];
		NSMutableArray *deleteArray = [[NSMutableArray alloc] init];
		for(EquityNotificationEntity *notify in waitQueue)
			if(notify.notifiyTarget == entity)
				[deleteArray addObject:notify];
		[waitQueue removeObjectsInArray:deleteArray];
		if([waitQueue count] == 0)
			[dictRmoveKey addObject:key];
	}
	for(key in dictRmoveKey)
		[agentCounter removeObjectForKey:key];
	
	[notifyLock unlock];
}

@end
