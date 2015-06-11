//
//  NotifyAgent.h
//  Bullseye
//
//  Created by johaiyu on 2009/2/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NotifyAgent : NSObject 
{
	NSRecursiveLock *notifyLock;
	NSMutableDictionary *agentCounter;
}

- (void)addKey:(NSObject *)key Entity:(NSObject *)entity;
- (NSArray *)getTriggeredEntities:(NSObject *)key;
- (void)removeAllEntitiesForKey:(NSObject *)key;
- (void)removeKey:(NSObject *)key Entity:(NSObject *)entity;
- (void)addEntityForAll:(NSObject *)entity;
@end
