//
//  NotifyAgent.m
//  Bullseye
//
//  Created by johaiyu on 2009/2/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NotifyAgent.h"
#import "EquityNotification.h"

@interface NotifyAgent ()
@property (nonatomic, strong) NSMutableDictionary *agentCounter;
@end

@implementation NotifyAgent

@synthesize agentCounter;

- (id)init
{
	if (self = [super init])
	{
		notifyLock = [[NSRecursiveLock alloc] init];
		agentCounter = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (void)addKey:(NSObject<NSCopying> *)key Entity:(NSObject *)entity
{
	[notifyLock lock];
	NSMutableArray *waitQueue = [agentCounter objectForKey:key];
	if (!waitQueue)
	{
        if (key!=nil) {
            waitQueue = [[NSMutableArray alloc] init];
            [agentCounter setObject:waitQueue forKey:key];
        }
		
	}
	[waitQueue addObject:entity];
	[notifyLock unlock];
}

- (void)addEntityForAll:(NSObject *)entity
{
	[notifyLock lock];
	NSArray *tmpQueue = [agentCounter allValues];
	for (NSMutableArray *queue in tmpQueue)
		[queue addObject:entity];
	[notifyLock unlock];
}

- (NSArray *)getTriggeredEntities:(NSObject *)key
{
	[notifyLock lock];
	NSMutableArray *waitQueue = [agentCounter objectForKey:key];
	[notifyLock unlock];
	return waitQueue;
}

- (void)removeKey:(NSObject *)key Entity:(NSObject *)entity
{
	[notifyLock lock];
	NSMutableArray *waitQueue = [agentCounter objectForKey:key];
	if (waitQueue)
	{
		[waitQueue removeObject:entity];
		if (![waitQueue count])
			// Remove empty waiting queue.
			[agentCounter removeObjectForKey:key];
	}
	[notifyLock unlock];
}

- (void)removeAllEntitiesForKey:(NSObject *)key
{
	[notifyLock lock];
	[agentCounter removeObjectForKey:key];
	[notifyLock unlock];
}

@end
