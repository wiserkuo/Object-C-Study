//
//  SectorTableIn.m
//  Bullseye
//
//  Created by Yehsam on 2008/11/25.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SectorTableIn.h"
#import "FSCategoryTree.h"


@implementation SectorTableIn

@synthesize sectorAdd;
@synthesize sectorRemove;

- (id)init
{
	if (self = [super init])
	{
	}
	
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	
	retCode = retcode;
	sectorDate = [CodingUtil getUInt16:body];
	body+=2;
	sectorCount = [CodingUtil getUInt16:body];
	body+=2;
	sectorAdd = [[NSMutableArray alloc] init];
	for(int i=0 ; i<sectorCount ; i++)
	{
		AddSector *add = [[AddSector alloc] init];
		add->sectorIDAdd = [CodingUtil getUInt16:body];
		body+=2;
		add->flag = *body++;
		add->sectorType = [CodingUtil getUInt16:body];
		body+=2;
		add->sectorOrder = *body++;
		add->nameLength = *body++;
		add->sectorName = [[NSString alloc] initWithBytes:body length:add->nameLength encoding:NSUTF8StringEncoding];
		body+= add->nameLength;
		add->superID = [CodingUtil getUInt16:body];
		body+=2;
		if(add->superID == 0)
		{
			add->marketIDCount = *body++;
			add->marketID = malloc(add->marketIDCount);
			for(int i=0 ; i<add->marketIDCount ; i++)
				add->marketID[i] = *body++;
		}
		else
		{
			add->marketIDCount = 0;
			add->marketID = 0;
		}
		[sectorAdd addObject:add];
	}
	
//	[cat performSelector:@selector(addCategory:) onThread:datamodal.thread withObject:sectorAdd waitUntilDone:NO];
	sectorToRemoveCount = [CodingUtil getUInt16:body];
	body+=2;
	sectorRemove = [[NSMutableArray alloc] init];
	for(int i=0 ; i<sectorToRemoveCount ; i++)
	{
		RemoveSector *remove = [[RemoveSector alloc] init];
		remove->sectorIDRemove = [CodingUtil getUInt16:body]; 
		[sectorRemove addObject:remove];
		body+=2;
	}
	body = tmpPtr;
	//not used

    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
	FSCategoryTree *category = dataModel.category;
	[category performSelector:@selector(updateCategory:) onThread:dataModel.thread withObject:self waitUntilDone:NO];

//	[cat performSelector:@selector(removeCategory:) onThread:datamodal.thread withObject:sectorRemove waitUntilDone:NO];
//	if (retcode == 0)
//	{
//		NSNumber  *syncDate = [[NSNumber alloc]initWithInt:sectorDate];
//		[cat performSelector:@selector(updateCategory:) onThread:datamodal.thread withObject:syncDate waitUntilDone:NO];
//		[syncDate release];
//	}
}

@end

@implementation AddSector

@synthesize sectorName;

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

- (void) dealloc
{
	if (marketID)
		free(marketID);
}

@end

@implementation RemoveSector

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

@end

