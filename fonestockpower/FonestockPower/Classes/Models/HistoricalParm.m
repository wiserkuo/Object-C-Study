//
//  HistoricalParm.m
//  Bullseye
//
//  Created by Yehsam on 2008/12/18.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HistoricalParm.h"


@implementation HistoricalParm

@synthesize historicalDataArray;

- (id)init
{
	if(self = [super init])
	{
		historicalDataArray = [[NSMutableArray alloc] init];
	}
	return self;
}

@end

/*                      Format 1 & 2                  */


@implementation HistoricalDataFormat1

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

@end

@implementation HistoricalDataFormat2

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}


@end

