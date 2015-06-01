//
//  WatchLists.h
//  FonestockPower
//
//  Created by Neil on 14/4/29.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WatchGroup : NSObject{
	
    int  groupID;
	NSString* groupName;
	int isCategory;
	NSRecursiveLock *watchGroupLock;
}

@property(nonatomic,readwrite) int groupID;
@property(nonatomic,strong) NSString *groupName;
@property(nonatomic,readwrite) int isCategory;

@end


@interface WatchLists : NSObject{
    NSMutableArray *watchs;
}

@property(nonatomic,strong) NSMutableArray *watchs;

- (int)getWatchGroupCount;
- (WatchGroup *)getWatchGroupWithWatchGroupIndex:(int)index;
- (int)getWatchsIndexByWatchGroupID:(int)gID;
- (WatchLists*)updataWatchlists;
@end
