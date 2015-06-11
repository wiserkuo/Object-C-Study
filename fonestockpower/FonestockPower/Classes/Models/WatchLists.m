//
//  WatchLists.m
//  FonestockPower
//
//  Created by Neil on 14/4/29.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "WatchLists.h"

@implementation WatchGroup

@synthesize groupID;
@synthesize groupName;
@synthesize isCategory;

@end

@implementation WatchLists

@synthesize watchs;

- (WatchLists*) init
{
	self = [super init];
	if (self)
	{
		watchs = [[NSMutableArray alloc]init];
		[WatchLists loadAllWatchGroupWithWatchs:watchs]; // get watch group data from db
	}
	
	return self;
}

- (int)getWatchGroupCount {
	
	int watchGroupCount = 0;
	for(WatchGroup *watchGroup in watchs)
	{
		if(watchGroup.isCategory == 0)
			watchGroupCount++;
	}
	
	return watchGroupCount;
    
}

+ (void)loadAllWatchGroupWithWatchs:(NSMutableArray *)watchGroupArray{
	
	// all group
	NSString *AllLabel = NSLocalizedStringFromTable(@"All", @"watchlists", @"allLabel");
	WatchGroup *node = [[WatchGroup alloc] init];
	node.groupName = AllLabel;
	node.groupID = 0;
	node.isCategory = 0;
	[watchGroupArray addObject: node];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *message = [db executeQuery:@"SELECT GroupName, GroupID,isCategory FROM groupName order by GroupIndex"];
        while ([message next]) {
            WatchGroup *node = [[WatchGroup alloc] init];
            node.groupName = [message stringForColumn:@"GroupName"];
            node.groupID = [message intForColumn:@"GroupID"];
            node.isCategory = [message intForColumn:@"isCategory"];
            [watchGroupArray addObject: node];
        }
    }];
}

- (WatchGroup *)getWatchGroupWithWatchGroupIndex:(int)index {
	
	//在 watchs中 找第idnex比自選群組
	int tmpWatchIndex = -1;
	for(WatchGroup *watchGroup in watchs)
	{
		if(watchGroup.isCategory == 0) //只排自選群組 (略過分類最愛)
		{
			tmpWatchIndex++;
			if(tmpWatchIndex == index)
				return watchGroup;
		} 
	}
	return nil;
}

- (int)getWatchsIndexByWatchGroupID:(int)gID {
	
	int index = -1;
	for(WatchGroup *watchGroup in watchs)
	{
		index++;
		if(watchGroup.isCategory == 0 && watchGroup.groupID == gID)
			return index;      
	}
	return index;
}


-(WatchLists*)updataWatchlists
{
    watchs = [[NSMutableArray alloc]init];
    [WatchLists loadAllWatchGroupWithWatchs:watchs];
    return self;
}


@end
