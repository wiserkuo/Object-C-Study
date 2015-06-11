//
//  Brokers.m
//  Bullseye
//
//  Created by Yehsam on 2009/6/12.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "Brokers.h"

#import "BrokersByOut.h"
#import "BrokersByIn.h"

@implementation Brokers

@synthesize mainStockArray;
@synthesize mainBrokerArray;
@synthesize mainAnchorArray;
@synthesize mainNewBrokerArray;
@synthesize recordDate;

- (id)init
{
	if(self = [super init])
	{
		datalock = [[NSRecursiveLock alloc] init];
	}
	return self;
}

- (void)sendByStockID:(UInt32)cn WithDay:(UInt8)dayCounts BrokersCount:(UInt8)brokersCount SortType:(UInt8)st
{
	[datalock lock];
	if(!mainStockArray) mainStockArray = [[NSMutableArray alloc] init];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *today = [NSDate date];
	NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
	int year = (int)[comps year];
	int month = (int)[comps month];
	int day = (int)[comps day];
	UInt16 eDate;
	eDate = [CodingUtil makeDate:year month:month day:day];
	commodityNum = cn;
	
    BrokersByStockOut *bbsOut = [[BrokersByStockOut alloc] initWithSecurityNum:cn RecordDate:eDate DayType:dayCounts CountType:brokersCount SortType:st];
//	BrokersByStockOut *bbsOut = [[BrokersByStockOut alloc] initWithSecurityNum:cn RecordDate:eDate Days:dayCounts Counts:brokersCount SortType:st];
	[FSDataModelProc sendData:self WithPacket:bbsOut];
	removeFlagByStock = YES;
	[datalock unlock];

}

- (void)sendByBrokerID:(UInt16)bID WithDay:(UInt8)dayCounts BrokersCount:(UInt8)brokersCount
{
	[datalock lock];
	if(!mainBrokerArray) mainBrokerArray = [[NSMutableArray alloc] init];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *today = [NSDate date];
	NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
    int year = (int)[comps year];
    int month = (int)[comps month];
    int day = (int)[comps day];
	UInt16 eDate;
	eDate = [CodingUtil makeDate:year month:month day:day];
	brokerID = bID;
	
	BrokersByBrokerOut *bbOut = [[BrokersByBrokerOut alloc] initWithBrokerID:bID RecordDate:eDate Days:dayCounts Counts:brokersCount];
	[FSDataModelProc sendData:self WithPacket:bbOut];
	removeFlagByBroker = YES;
	[datalock unlock];
}

- (void)sendByAnchor:(UInt32)cn BrokerID:(UInt16)bID BrokersCount:(UInt8)brokersCount
{
	[datalock lock];
	if(!mainAnchorArray) mainAnchorArray = [[NSMutableArray alloc] init];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *today = [NSDate date];
	NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
	int year = (int)[comps year];
	int month = (int)[comps month];
	int day = (int)[comps day];
	UInt16 eDate;
	eDate = [CodingUtil makeDate:year month:month day:day];
	commodityNum = cn;
	brokerID = bID;
	BrokersByAnchorOut *baOut = [[BrokersByAnchorOut alloc] initWithSecurityNum:cn BrokerID:bID Count:brokersCount];
	[FSDataModelProc sendData:self WithPacket:baOut];
	removeFlagByAnchor = YES;
	[datalock unlock];
}

- (void)sendByNewBrokerID:(UInt16)bId WithDay:(UInt8)dayCounts BrokersCount:(UInt8)brokersCount SortType:(UInt8)st
{
    [datalock lock];
    if(!mainNewBrokerArray) mainNewBrokerArray = [[NSMutableArray alloc] init];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *today = [NSDate date];
    NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
    int year = (int)[comps year];
    int month = (int)[comps month];
    int day = (int)[comps day];
    UInt16 eDate;
    eDate = [CodingUtil makeDate:year month:month day:day];
    brokerID = bId;

    
    NewBrokersByBroker *bbsOut = [[NewBrokersByBroker alloc] initWithBrokerId:bId RecordDate:eDate DayType:dayCounts CountType:brokersCount SortType:st];
    //	BrokersByStockOut *bbsOut = [[BrokersByStockOut alloc] initWithSecurityNum:cn RecordDate:eDate Days:dayCounts Counts:brokersCount SortType:st];
    [FSDataModelProc sendData:self WithPacket:bbsOut];
    removeFlagByNewBroker = YES;
    [datalock unlock];
    
}

- (void)decodeByStockArrive:(BrokersByStockIn*)obj
{
	[datalock lock];
	if(commodityNum != obj->commodityNum)
	{
		[datalock unlock];
		return;
	}
	NSMutableArray *bf1Array = obj->brokersFormat1Array;
    recordDate = 0;
	if([bf1Array count]>0)
	{
		if(removeFlagByStock)
		{
			[mainStockArray removeAllObjects];
		}
        
        
        recordDate = obj->recordDate;
        
		for(BrokersFormat1 *bf1 in bf1Array)
		{
			NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
			[tmpDict setObject:[NSNumber numberWithUnsignedInt:bf1->brokerID] forKey:@"BrokerID"];
			[tmpDict setObject:[NSNumber numberWithDouble:bf1->buyShare * pow(1000,bf1->buyShareUnit)] forKey:@"BuyShare"];
			[tmpDict setObject:[NSNumber numberWithDouble:bf1->sellShare * pow(1000,bf1->sellShareUnit)] forKey:@"SellShare"];
			[tmpDict setObject:[NSNumber numberWithDouble:bf1->buyAmnt * pow(1000,bf1->buyAmntUnit)] forKey:@"BuyAmnt"];
			[tmpDict setObject:[NSNumber numberWithDouble:bf1->sellAmnt * pow(1000,bf1->sellAmntUnit)] forKey:@"SellAmnt"];
			
			double sum = 0;
			sum = (bf1->buyShare * pow(1000,bf1->buyShareUnit)) - (bf1->sellShare * pow(1000,bf1->sellShareUnit));
			[tmpDict setObject:[NSNumber numberWithDouble:sum] forKey:@"BuySellShare"];
			sum = (bf1->buyAmnt * pow(1000,bf1->buyAmntUnit)) - (bf1->sellAmnt * pow(1000,bf1->sellAmntUnit));
			[tmpDict setObject:[NSNumber numberWithDouble:sum] forKey:@"BuySellAmnt"];
			
			[mainStockArray addObject:tmpDict];
		}
		if(obj->returnCode == 0 && notifyObjByStock)
			[notifyObjByStock performSelectorOnMainThread:@selector(notifyData) withObject:mainStockArray waitUntilDone:NO];
    }else{
        [mainStockArray removeAllObjects];
        [notifyObjByStock performSelectorOnMainThread:@selector(notifyData) withObject:mainStockArray waitUntilDone:NO];

    }
	[datalock unlock];
	
}


- (void)decodeByBrokerArrive:(BrokersByBrokerIn*)obj
{
	[datalock lock];
	if(brokerID != obj->brokerID)
	{
		[datalock unlock];
		return;
	}
	NSMutableArray *bf2Array = obj->brokersFormat2Array;
	if([bf2Array count]>0)
	{
		if(removeFlagByBroker)
		{
			[mainBrokerArray removeAllObjects];
		}
		for(BrokersFormat2 *bf2 in bf2Array)
		{
			NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
			
			[tmpDict setObject:bf2.symbolInfo forKey:@"SymbolFormat1"];
			
			[tmpDict setObject:[NSNumber numberWithDouble:bf2->buyShare * pow(1000,bf2->buyShareUnit)] forKey:@"BuyShare"];
			[tmpDict setObject:[NSNumber numberWithDouble:bf2->sellShare * pow(1000,bf2->sellShareUnit)] forKey:@"SellShare"];
			[tmpDict setObject:[NSNumber numberWithDouble:bf2->buyAmnt * pow(1000,bf2->buyAmntUnit)] forKey:@"BuyAmnt"];
			[tmpDict setObject:[NSNumber numberWithDouble:bf2->sellAmnt * pow(1000,bf2->sellAmntUnit)] forKey:@"SellAmnt"];
			
			double sum = 0;
			sum = (bf2->buyShare * pow(1000,bf2->buyShareUnit)) - (bf2->sellShare * pow(1000,bf2->sellShareUnit));
			[tmpDict setObject:[NSNumber numberWithDouble:sum] forKey:@"BuySellShare"];
			sum = (bf2->buyAmnt * pow(1000,bf2->buyAmntUnit)) - (bf2->sellAmnt * pow(1000,bf2->sellAmntUnit));
			[tmpDict setObject:[NSNumber numberWithDouble:sum] forKey:@"BuySellAmnt"];
			
			
			[mainBrokerArray addObject:tmpDict];
		}
		if(obj->returnCode == 0 && notifyObjByBroker)
			[notifyObjByBroker performSelectorOnMainThread:@selector(notifyData) withObject:nil waitUntilDone:NO];
	}
	[datalock unlock];
	
	
}

- (void)decodeByAnchorArrive:(BrokersByAnchorIn*)obj
{
	[datalock lock];
	if(brokerID != obj->brokerID && commodityNum != obj->commodityNum)
	{
		[datalock unlock];
		return;
	}
	NSMutableArray *bf3Array = obj->brokersFormat3Array;
	if([bf3Array count]>0)
	{
		if(removeFlagByAnchor)
		{
			[mainAnchorArray removeAllObjects];
		}
		for(BrokersFormat3 *bf3 in bf3Array)
		{
			NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
			
			[tmpDict setObject:[NSNumber numberWithUnsignedInt:bf3->date] forKey:@"Date"];
			
			[tmpDict setObject:[NSNumber numberWithDouble:bf3->buyShare * pow(1000,bf3->buyShareUnit)] forKey:@"BuyShare"];
			[tmpDict setObject:[NSNumber numberWithDouble:bf3->sellShare * pow(1000,bf3->sellShareUnit)] forKey:@"SellShare"];
			[tmpDict setObject:[NSNumber numberWithDouble:bf3->buyAmnt * pow(1000,bf3->buyAmntUnit)] forKey:@"BuyAmnt"];
			[tmpDict setObject:[NSNumber numberWithDouble:bf3->sellAmnt * pow(1000,bf3->sellAmntUnit)] forKey:@"SellAmnt"];
			
			double sum = 0;
			sum = (bf3->buyShare * pow(1000,bf3->buyShareUnit)) - (bf3->sellShare * pow(1000,bf3->sellShareUnit));
			[tmpDict setObject:[NSNumber numberWithDouble:sum] forKey:@"BuySellShare"];
			sum = (bf3->buyAmnt * pow(1000,bf3->buyAmntUnit)) - (bf3->sellAmnt * pow(1000,bf3->sellAmntUnit));
			[tmpDict setObject:[NSNumber numberWithDouble:sum] forKey:@"BuySellAmnt"];
			
			[mainAnchorArray addObject:tmpDict];
		}
		if(obj->returnCode == 0 && notifyObjByAnchor)
			[notifyObjByAnchor performSelectorOnMainThread:@selector(notifyData) withObject:nil waitUntilDone:NO];
	}
	[datalock unlock];
}
//2 , 31
- (void)decodeByNewBrokerArrive:(NewBrokersByBrokerIn*)obj
{
    [datalock lock];
    if(brokerID != obj->brokerID)
    {
        [datalock unlock];
        return;
    }
    NSMutableArray *bf2Array = obj->brokersFormat2Array;
    if([bf2Array count]>0)
    {
        if(removeFlagByNewBroker)
        {
            [mainNewBrokerArray removeAllObjects];
        }
        for(BrokersFormat2 *bf2 in bf2Array)
        {
            NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
            
            [tmpDict setObject:bf2.symbolInfo forKey:@"SymbolFormat1"];
            
            [tmpDict setObject:[NSNumber numberWithDouble:bf2->buyShare * pow(1000,bf2->buyShareUnit)] forKey:@"BuyShare"];
            [tmpDict setObject:[NSNumber numberWithDouble:bf2->sellShare * pow(1000,bf2->sellShareUnit)] forKey:@"SellShare"];
            [tmpDict setObject:[NSNumber numberWithDouble:bf2->buyAmnt * pow(1000,bf2->buyAmntUnit)] forKey:@"BuyAmnt"];
            [tmpDict setObject:[NSNumber numberWithDouble:bf2->sellAmnt * pow(1000,bf2->sellAmntUnit)] forKey:@"SellAmnt"];
            
            double sum = 0;
            sum = (bf2->buyShare * pow(1000,bf2->buyShareUnit)) - (bf2->sellShare * pow(1000,bf2->sellShareUnit));
            [tmpDict setObject:[NSNumber numberWithDouble:sum] forKey:@"BuySellShare"];
            sum = (bf2->buyAmnt * pow(1000,bf2->buyAmntUnit)) - (bf2->sellAmnt * pow(1000,bf2->sellAmntUnit));
            [tmpDict setObject:[NSNumber numberWithDouble:sum] forKey:@"BuySellAmnt"];
            
            
            [mainNewBrokerArray addObject:tmpDict];
        }
        if(obj->returnCode == 0 && notifyObjByNewBroker)
            [notifyObjByNewBroker performSelectorOnMainThread:@selector(notifyData) withObject:nil waitUntilDone:NO];
    }
    [datalock unlock];
}

- (void)setTargetNotifyByStock:(id)obj
{
	[datalock lock];
	notifyObjByStock = obj;
	[datalock unlock];
}

- (void)setTargetNotifyByBroker:(id)obj
{
	[datalock lock];
	notifyObjByBroker = obj;
	[datalock unlock];
}

- (void)setTargetNotifyByAnchor:(id)obj
{
	[datalock lock];
	notifyObjByAnchor = obj;
	[datalock unlock];
}

- (void)setTargetNotifyByNewBroker:(id)obj
{
    [datalock lock];
    notifyObjByNewBroker = obj;
    [datalock unlock];
}

- (void)sortArrayByStock:(SortType)st ascending:(BOOL)ascending
{
	[datalock lock];
	NSString *key;
	switch (st) {
		case BuyShare:
			key = @"BuyShare";
			break;
		case SellShare:
			key = @"SellShare";
			break;
		case BuySellShare:
			key = @"BuySellShare";
			break;
		case BuyAmnt:
			key = @"BuyAmnt";
			break;
		case SellAmnt:
			key = @"SellAmnt";
			break;
		case BuySellAmnt:
			key = @"BuySellAmnt";
			break;
		default:
			break;
	}
	
	
	NSSortDescriptor *sortDescriptor;
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending selector:@selector(compare:)];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	[mainStockArray sortUsingDescriptors:sortDescriptors];
	[datalock unlock];
}

- (void)sortArrayByBroker:(SortType)st
{
	[datalock lock];
	NSString *key;
	switch (st) {
		case BuyShare:
			key = @"BuyShare";
			break;
		case SellShare:
			key = @"SellShare";
			break;
		case BuySellShare:
			key = @"BuySellShare";
			break;
		case BuyAmnt:
			key = @"BuyAmnt";
			break;
		case SellAmnt:
			key = @"SellAmnt";
			break;
		case BuySellAmnt:
			key = @"BuySellAmnt";
			break;
		default:
			break;
	}
	
	
	NSSortDescriptor *sortDescriptor;
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:NO selector:@selector(compare:)];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	[mainBrokerArray sortUsingDescriptors:sortDescriptors];
	[datalock unlock];
}

- (void)sortArrayByAnchor:(SortType)st
{
	[datalock lock];
	NSString *key;
	switch (st) {
		case BuyShare:
			key = @"BuyShare";
			break;
		case SellShare:
			key = @"SellShare";
			break;
		case BuySellShare:
			key = @"BuySellShare";
			break;
		case BuyAmnt:
			key = @"BuyAmnt";
			break;
		case SellAmnt:
			key = @"SellAmnt";
			break;
		case BuySellAmnt:
			key = @"BuySellAmnt";
			break;
		default:
			break;
	}
	
	
	NSSortDescriptor *sortDescriptor;
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:NO selector:@selector(compare:)];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	[mainAnchorArray sortUsingDescriptors:sortDescriptors];
	[datalock unlock];
}


- (int)getRowCountByStock
{
	[datalock lock];
	int count = (int)[mainStockArray count];
	[datalock unlock];
	return count;
}

- (int)getRowCountByBroker
{
	[datalock lock];
	int count = (int)[mainBrokerArray count];
	[datalock unlock];
	return count;
}

- (int)getRowCountByAnchor
{
	[datalock lock];
	int count = (int)[mainAnchorArray count];
	[datalock unlock];
	return count;
}

- (BrokersFormat1*)getAllocRowDataByStockIndex:(int)indexRow
{
	[datalock lock];
	BrokersFormat1 *bf1 = nil;
	if(indexRow < [mainStockArray count])
	{
		bf1 = [[BrokersFormat1 alloc] init];
		NSDictionary *tmpDict = [mainStockArray objectAtIndex:indexRow];
		bf1->brokerID = [[tmpDict objectForKey:@"BrokerID"] unsignedIntValue];
		bf1->buyShare = [(NSNumber *)[tmpDict objectForKey:@"BuyShare"] doubleValue];
		bf1->buyShareUnit = 0;
		bf1->sellShare = [(NSNumber *)[tmpDict objectForKey:@"SellShare"] doubleValue];
		bf1->sellShareUnit = 0;
		bf1->buyAmnt = [(NSNumber *)[tmpDict objectForKey:@"BuyAmnt"] doubleValue];
		bf1->buyAmntUnit = 0;
		bf1->sellAmnt = [(NSNumber *)[tmpDict objectForKey:@"SellAmnt"] doubleValue];
		bf1->sellAmntUnit = 0;
        bf1->sellAmnt = [(NSNumber *)[tmpDict objectForKey:@"SellAmnt"] doubleValue];
		bf1->sellAmntUnit = 0;
        bf1->buysellShare = [(NSNumber *)[tmpDict objectForKey:@"BuySellShare"] doubleValue];
        bf1->buysellAmnt = [(NSNumber *)[tmpDict objectForKey:@"BuySellAmnt"]intValue];
	}
	[datalock unlock];
	return bf1;
}

- (BrokersFormat2*)getAllocRowDataByBrokerIndex:(int)indexRow
{
	[datalock lock];
	BrokersFormat2 *bf2 = nil;
	if(indexRow < [mainBrokerArray count])
	{
		bf2 = [[BrokersFormat2 alloc] init];
		NSDictionary *tmpDict = [mainBrokerArray objectAtIndex:indexRow];
		bf2.symbolInfo = [tmpDict objectForKey:@"SymbolFormat1"];
		bf2->buyShare = [(NSNumber *)[tmpDict objectForKey:@"BuyShare"] doubleValue];
		bf2->buyShareUnit = 0;
		bf2->sellShare = [(NSNumber *)[tmpDict objectForKey:@"SellShare"] doubleValue];
		bf2->sellShareUnit = 0;
		bf2->buyAmnt = [(NSNumber *)[tmpDict objectForKey:@"BuyAmnt"] doubleValue];
		bf2->buyAmntUnit = 0;
		bf2->sellAmnt = [(NSNumber *)[tmpDict objectForKey:@"SellAmnt"] doubleValue];
		bf2->sellAmntUnit = 0;
	}
	[datalock unlock];
	return bf2;
}

- (BrokersFormat3*)getAllocRowDataByAnchorIndex:(int)indexRow
{
	[datalock lock];
	BrokersFormat3 *bf3 = nil;
	if(indexRow < [mainAnchorArray count])
	{
		bf3 = [[BrokersFormat3 alloc] init];
		NSDictionary *tmpDict = [mainAnchorArray objectAtIndex:indexRow];
		bf3->date = [[tmpDict objectForKey:@"Date"] unsignedIntValue];
		bf3->buyShare = [(NSNumber *)[tmpDict objectForKey:@"BuyShare"] doubleValue];
		bf3->buyShareUnit = 0;
		bf3->sellShare = [(NSNumber *)[tmpDict objectForKey:@"SellShare"] doubleValue];
		bf3->sellShareUnit = 0;
		bf3->buyAmnt = [(NSNumber *)[tmpDict objectForKey:@"BuyAmnt"] doubleValue];
		bf3->buyAmntUnit = 0;
		bf3->sellAmnt = [(NSNumber *)[tmpDict objectForKey:@"SellAmnt"] doubleValue];
		bf3->sellAmntUnit = 0;
	}
	[datalock unlock];
	return bf3;
}



- (void)discardDataByStock
{
	[datalock lock];
	self.mainStockArray = nil;
	notifyObjByStock = nil;
	commodityNum = 0;
	[datalock unlock];
}

- (void)discardDataByBroker
{
	[datalock lock];
	self.mainBrokerArray = nil;
	notifyObjByBroker = nil;
	brokerID = 0;
	[datalock unlock];
}

- (void)discardDataByAnchor
{
	[datalock lock];
	self.mainAnchorArray = nil;
	notifyObjByAnchor = nil;
	commodityNum = 0;
	brokerID = 0;
	[datalock unlock];
}

@end
@implementation BrokersByModel

+ (BrokersByModel *)sharedInstance
{
    static BrokersByModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BrokersByModel alloc] init];
    });
    return sharedInstance;
}

@end