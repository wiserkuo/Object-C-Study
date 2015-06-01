//
//  EquityHistory.m
//  FonestockPower
//
//  Created by Neil on 14/5/5.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "EquityHistory.h"
#import "HistoricDataTypes.h"

#define MAX_HISTORY_CELL_COUNT    20
#define HISTORY_COUNT_PER_CELL   100

#define COMMODITY_TYPE_STOCK    1
#define COMMODITY_TYPE_WARRANT  2
#define COMMODITY_TYPE_INDEX    3
#define COMMODITY_TYPE_FUTURE   4
#define COMMODITY_TYPE_OPTION   5
#define COMMODITY_TYPE_MARKET_INDEX   6
#define COMMODITY_TYPE_ETF      7

const int MinutePeriod = 5;

static UInt16 RoundMinuteTime(UInt16 time, UInt16 openTime, UInt16 closeTime)
{
	time = time / MinutePeriod * MinutePeriod + openTime + MinutePeriod;
	if (time > closeTime) time = closeTime;
	return time;
}

static UInt16 RoundMinuteTimeByMinutePeriod(UInt16 time, UInt16 openTime, UInt16 closeTime, UInt16 minutePeriod)
{
	time = time / minutePeriod * minutePeriod + openTime + minutePeriod;
	if (time > closeTime) time = closeTime;
	return time;
}

@interface EquityHistory (){
    NSString *identCodeSymbol;
	UInt8 commodityType;
	NSRecursiveLock *lock;
    
    BOOL fivem_dirty;
	BOOL day_dirty;
	BOOL week_dirty;
	BOOL month_dirty;
    
    int todayfivem_count;
    int fivem_count;
	int day_count;
	int week_count;
	int month_count;
    
    UInt16 latestFivem;
	UInt32 latestFivemTime;
	UInt16 latestDay;
	UInt16 latestWeek;
	UInt16 latestMonth;
    
    BOOL fivem_islatest;
	BOOL day_islatest;
	BOOL week_islatest;
	BOOL month_islatest;
    
    int  fivem_count_cell[MAX_HISTORY_CELL_COUNT];
	Historic5Minute *fivem[MAX_HISTORY_CELL_COUNT];
	void /*HistoricData*/ *day[MAX_HISTORY_CELL_COUNT];
	void /*HistoricData*/ *week[MAX_HISTORY_CELL_COUNT];
	void /*HistoricData*/ *month[MAX_HISTORY_CELL_COUNT];
    
    NSMutableArray *todayfivem;
    NSMutableArray *todayOtherM;

}

@end

@implementation EquityHistory

- (id)init
{
	if(self = [super init])
	{
		identCodeSymbol = nil;
		todayfivem = [[NSMutableArray alloc] init];
		todayOtherM = [[NSMutableArray alloc] init];
		for (int i = 0; i < MAX_HISTORY_CELL_COUNT; i++)
		{
			fivem_count_cell[i] = 0;
			fivem[i] = NULL;
			day[i] = NULL;
			week[i] = NULL;
			month[i] = NULL;
		}
		todayfivem_count = 0;
		fivem_count = 0;
		day_count = 0;
		week_count = 0;
		month_count = 0;
		latestFivem = 0;
		latestFivemTime = 0;
		latestDay = 0;
		latestWeek = 0;
		latestMonth = 0;
		fivem_dirty = NO;
		day_dirty =  NO;
		week_dirty = NO;
		month_dirty = NO;
		fivem_islatest = NO;
		day_islatest = NO;
		week_islatest = NO;
		month_islatest = NO;
		lock = [[NSRecursiveLock alloc] init];
	}
	return self;
}


- (void)assignIdentCodeSymbol:(NSString *)identSymbol
{
	identCodeSymbol = identSymbol;
}

- (NSString *)getIdenCodeSymbol
{
	return identCodeSymbol;
}

- (BOOL)loadFromFile:(UInt8) type
{
	//if (identCodeSymbol != nil)  [identCodeSymbol release];
	//identCodeSymbol = [identSymbol retain];
	if (identCodeSymbol == nil) return NO;
	commodityType = type;
	
	[self loadWithTickType: '5'];
	[self loadWithTickType: 'D'];
	[self loadWithTickType: 'W'];
	[self loadWithTickType: 'M'];
	return YES;
}

- (BOOL)loadWithTickType:(UInt8) tickType
{
	[lock lock];
	NSFileHandle *readFile = [NSFileHandle fileHandleForReadingAtPath:[self pfName:tickType]];
	if (readFile == nil)
	{
		[lock unlock];
		return NO;
	}
	while (1 == 1)
	{
		if (tickType == '5')
		{
			Historic5Minute tick;
			NSData *fileData;
			fileData = [readFile readDataOfLength:sizeof(tick)];
			if ([fileData length] != sizeof(tick))  break;
			[fileData getBytes: &tick];
			[self addHistoricTick: (HistoricData*)&tick tickType: tickType];
		}
		else if (commodityType == COMMODITY_TYPE_FUTURE)
		{
			HistoricFuture tick;
			NSData *fileData;
			fileData = [readFile readDataOfLength:sizeof(tick)];
			if ([fileData length] != sizeof(tick))  break;
			[fileData getBytes: &tick];
			[self addHistoricTick: (HistoricData*)&tick tickType: tickType];
		}
		else
		{
			HistoricData tick;
			NSData *fileData;
			fileData = [readFile readDataOfLength:sizeof(tick)];
			if ([fileData length] != sizeof(tick))  break;
			[fileData getBytes: &tick];
			[self addHistoricTick: (HistoricData*)&tick tickType: tickType];
		}
	}
	[readFile closeFile];
	switch (tickType)
	{
		case '5': fivem_dirty = NO; break;
		case 'D': day_dirty = NO;   break;
		case 'W': week_dirty = NO;  break;
		case 'M': month_dirty = NO; break;
	}
	[lock unlock];
	return YES;
}

- (NSString*) pfName:(UInt8) tickType
{
	NSString *pfFileName;
    
	NSString *documentsDirectory = [CodingUtil techLineDataDirectoryPath];
	pfFileName = [documentsDirectory stringByAppendingPathComponent:identCodeSymbol];
	
	switch (tickType)
	{
		case '5':
		case 'F':
		case 'T':
		case 'S':
			return [pfFileName stringByAppendingPathExtension:@"5min"];
		case 'D': return [pfFileName stringByAppendingPathExtension:@"day"];
		case 'W': return [pfFileName stringByAppendingPathExtension:@"week"];
		case 'M': return [pfFileName stringByAppendingPathExtension:@"month"];
		default: return nil;
	}
    
	return nil;
}

- (BOOL)addHistoricTick:(HistoricData*) tick tickType:(UInt8) tickType
{
    [lock lock];
	int cell, pos;
	if (tickType == '5')
	{
		Historic5Minute *newfivem = (Historic5Minute *) tick;
		pos = -1;
		for (cell = 0; cell < MAX_HISTORY_CELL_COUNT; cell++)
		{
			if (fivem_count_cell[cell] == 0)
			{
				if (fivem[cell] == NULL)
				{
					fivem[cell] = malloc(sizeof(Historic5Minute)*HISTORY_COUNT_PER_CELL);
					if (fivem[cell] == NULL){
                        [lock unlock];
                        return NO;
                    }
				}
				pos = 0;
				break;
			}
			else if (newfivem->hisData.date == fivem[cell][0].hisData.date)
			{
				pos = fivem_count_cell[cell];
				for (int i = 0; i < pos; i++)
				{
					if (newfivem->time <= fivem[cell][i].time)
					{
						pos = -1;
						break;
					}
				}
				break;
			}
			else if (newfivem->hisData.date < fivem[cell][0].hisData.date)
			{
				if (fivem_count_cell[MAX_HISTORY_CELL_COUNT-1] == 0)
				{
					Historic5Minute *tmp = malloc(sizeof(Historic5Minute)*HISTORY_COUNT_PER_CELL);
					if (tmp == NULL){
                        [lock unlock];
                        return NO;
                    }
					for (int i = MAX_HISTORY_CELL_COUNT-1; i > cell; i--)
					{
						fivem[i] = fivem[i-1];
						fivem_count_cell[i] = fivem_count_cell[i-1];
					}
					fivem[cell] = tmp;
					fivem_count_cell[cell] = 0;
					pos = 0;
				}
				else
				{
					Historic5Minute *tmp = fivem[0];
					if (cell == 0){
                        [lock unlock];
                        return NO;
                    }
					cell--;
					for (int i = 0; i < cell; i++)
					{
						fivem[i] = fivem[i+1];
						fivem_count_cell[i] = fivem_count_cell[i+1];
					}
					fivem[cell] = tmp;
					fivem_count_cell[cell] = 0;
					pos = 0;
				}
				break;
			}
		}
		if (cell >= MAX_HISTORY_CELL_COUNT)
		{
			Historic5Minute *tmp = fivem[0];
			int tmpcount = fivem_count_cell[0];
			if (tmp == NULL) tmp = malloc(sizeof(Historic5Minute)*HISTORY_COUNT_PER_CELL);
			if (tmp == NULL) {
                [lock unlock];
                return NO;
            }
			cell = MAX_HISTORY_CELL_COUNT-1;
			for (int i = 0; i < MAX_HISTORY_CELL_COUNT-1; i++)
			{
                fivem[i] = fivem[i+1];
                fivem_count_cell[i] = fivem_count_cell[i+1];
			}
			fivem[cell] = tmp;
			fivem_count_cell[cell] = 0;
			fivem_count -= tmpcount;
			pos = 0;
		}
		if (pos < 0 || pos >= HISTORY_COUNT_PER_CELL) {
            [lock unlock];
			return NO;
        }
        
		fivem[cell][pos] = *newfivem;
		fivem_count_cell[cell]++;
		fivem_count++;
		if (latestFivem < newfivem->hisData.date
			|| (latestFivem == newfivem->hisData.date && latestFivemTime < newfivem->time))
		{
			latestFivem = newfivem->hisData.date;
			latestFivemTime = newfivem->time;
		}
        [lock unlock];
		return YES;
	}
	
	if (commodityType == COMMODITY_TYPE_FUTURE)
	{
		HistoricFuture *newtick = (HistoricFuture *) tick;
		switch (tickType)
		{
			case 'D':
				if (latestDay >= newtick->hisData.date){
                    [lock unlock];
                    return NO;
                }
				cell = day_count / HISTORY_COUNT_PER_CELL;
				pos  = day_count % HISTORY_COUNT_PER_CELL;
				if (cell >= MAX_HISTORY_CELL_COUNT-1)
				{
					void *temp = day[0];
					for (int i = 0; i < MAX_HISTORY_CELL_COUNT-1; i++)
						day[i] = day[i+1];
					day[MAX_HISTORY_CELL_COUNT-1] = temp;
					day_count -= HISTORY_COUNT_PER_CELL;
				}
				if (day[cell] == NULL)
				{
					day[cell] = malloc(sizeof(HistoricFuture)*HISTORY_COUNT_PER_CELL);
					if (day[cell] == NULL){
                        [lock unlock];
                        return NO;
                    }
				}
				((HistoricFuture*)(day[cell]))[pos] = *newtick;
				day_count++;
				latestDay = newtick->hisData.date;
				break;
			case 'W':
				if (latestWeek >= newtick->hisData.date) {
                    [lock unlock];
                    return NO;
                }
				cell = week_count / HISTORY_COUNT_PER_CELL;
				pos  = week_count % HISTORY_COUNT_PER_CELL;
				if (cell >= MAX_HISTORY_CELL_COUNT)
				{
					void *temp = week[0];
					for (int i = 0; i < MAX_HISTORY_CELL_COUNT-1; i++)
						week[i] = week[i+1];
					week[MAX_HISTORY_CELL_COUNT-1] = temp;
					week_count -= HISTORY_COUNT_PER_CELL;
				}
				if (week[cell] == NULL)
				{
					week[cell] = malloc(sizeof(HistoricFuture)*HISTORY_COUNT_PER_CELL);
					if (week[cell] == NULL){
                        [lock unlock];
                        return NO;
                    }
				}
				((HistoricFuture*)(week[cell]))[pos] = *newtick;
				week_count++;
				latestWeek = newtick->hisData.date;
				break;
			case 'M':
				if (latestMonth >= newtick->hisData.date){
                    [lock unlock];
                    return NO;
                }
				cell = month_count / HISTORY_COUNT_PER_CELL;
				pos  = month_count % HISTORY_COUNT_PER_CELL;
				if (cell >= MAX_HISTORY_CELL_COUNT)
				{
					void *temp = month[0];
					for (int i = 0; i < MAX_HISTORY_CELL_COUNT-1; i++)
						month[i] = month[i+1];
					month[MAX_HISTORY_CELL_COUNT-1] = temp;
					month_count -= HISTORY_COUNT_PER_CELL;
				}
				if (month[cell] == NULL)
				{
					month[cell] = malloc(sizeof(HistoricFuture)*HISTORY_COUNT_PER_CELL);
					if (month[cell] == NULL) {
                        [lock unlock];
                        return NO;
                    }
				}
				((HistoricFuture*)(month[cell]))[pos] = *newtick;
				month_count++;
				latestMonth = newtick->hisData.date;
				break;
			default:
                [lock unlock];
                return NO;
		}
        [lock unlock];
		return YES;
	}
	else
	{
		HistoricData *newtick = (HistoricData *) tick;
		switch (tickType)
		{
			case 'D':
				if (latestDay >= newtick->date) {
                    [lock unlock];
                    return NO;
                }
				cell = day_count / HISTORY_COUNT_PER_CELL;
				pos  = day_count % HISTORY_COUNT_PER_CELL;
				if (cell >= MAX_HISTORY_CELL_COUNT-1)
				{
					void *temp = day[0];
					for (int i = 0; i < MAX_HISTORY_CELL_COUNT-1; i++)
						day[i] = day[i+1];
					day[MAX_HISTORY_CELL_COUNT-1] = temp;
					day_count -= HISTORY_COUNT_PER_CELL;
				}
				if (day[cell] == NULL)
				{
					day[cell] = malloc(sizeof(HistoricData)*HISTORY_COUNT_PER_CELL);
					if (day[cell] == NULL){
                        [lock unlock];
                        return NO;
                    }
				}
				((HistoricData*)(day[cell]))[pos] = *newtick;
				day_count++;
				latestDay = newtick->date;
				break;
			case 'W':
				if (latestWeek >= newtick->date)
                {
                    [lock unlock];
                    return NO;
                }
				cell = week_count / HISTORY_COUNT_PER_CELL;
				pos  = week_count % HISTORY_COUNT_PER_CELL;
				if (cell >= MAX_HISTORY_CELL_COUNT)
				{
					void *temp = week[0];
					for (int i = 0; i < MAX_HISTORY_CELL_COUNT-1; i++)
						week[i] = week[i+1];
					week[MAX_HISTORY_CELL_COUNT-1] = temp;
					week_count -= HISTORY_COUNT_PER_CELL;
				}
				if (week[cell] == NULL)
				{
					week[cell] = malloc(sizeof(HistoricData)*HISTORY_COUNT_PER_CELL);
					if (week[cell] == NULL){
                        [lock unlock];
                        return NO;
                    }
				}
				((HistoricData*)(week[cell]))[pos] = *newtick;
				week_count++;
				latestWeek = newtick->date;
				break;
			case 'M':
				if (latestMonth >= newtick->date) {
                    [lock unlock];
                    return NO;
                }
				cell = month_count / HISTORY_COUNT_PER_CELL;
				pos  = month_count % HISTORY_COUNT_PER_CELL;
				if (cell >= MAX_HISTORY_CELL_COUNT)
				{
					void *temp = month[0];
					for (int i = 0; i < MAX_HISTORY_CELL_COUNT-1; i++)
						month[i] = month[i+1];
					month[MAX_HISTORY_CELL_COUNT-1] = temp;
					month_count -= HISTORY_COUNT_PER_CELL;
				}
				if (month[cell] == NULL)
				{
					month[cell] = malloc(sizeof(HistoricData)*HISTORY_COUNT_PER_CELL);
					if (month[cell] == NULL){
                        [lock unlock];
                        return NO;
                    }
				}
				((HistoricData*)(month[cell]))[pos] = *newtick;
				month_count++;
				latestMonth = newtick->date;
				break;
			default:
                [lock unlock];
                return NO;
		}
        [lock unlock];
		return YES;
	}
}

- (UInt16)quertyDataDate:(UInt8) tickType
{
	switch (tickType)
	{
		case '5':
		case 'F':
		case 'T':
		case 'S':
			return latestFivem;
		case 'D': return latestDay;
		case 'W': return latestWeek;
		case 'M': return latestMonth;
	}
	return 0;
}

- (void)setLatestData:(UInt8) type value:(BOOL)value;
{
	switch (type)
	{
		case '5':
		case 'F':
		case 'T':
		case 'S':
			fivem_islatest = value; break;
		case 'D': day_islatest = value; break;
		case 'W': week_islatest = value; break;
		case 'M': month_islatest = value; break;
	}
}

- (void)addHistoricTicks:(HistoricalParm*) param
{
	BOOL modify = NO;
	[lock lock];
	if (param->type == '5')
	{
		HistoricalDataFormat2 *item;
		UInt16 date;
		for (item in param->historicalDataArray)
		{
			Historic5Minute tick;
			if (item->dateFlag)  date = item->date;
			tick.hisData.date = date;
			tick.time = item->time;
			tick.hisData.open = item->openPrice;
			tick.hisData.high = item->highPrice;
			tick.hisData.low = item->lowPrice;
			tick.hisData.close = item->closePrice;
			tick.hisData.volume = item->volume;
			if ([self addHistoricTick: (HistoricData*)&tick tickType: param->type])
				modify = YES;
		}
	}
	else
	{
		if (commodityType == COMMODITY_TYPE_FUTURE)
		{
			HistoricalDataFormat1 *item;
			for (item in param->historicalDataArray)
			{
				HistoricFuture tick;
				tick.hisData.date = item->date;
				tick.hisData.open = item->openPrice;
				tick.hisData.high = item->highPrice;
				tick.hisData.low = item->lowPrice;
				tick.hisData.close = item->closePrice;
				tick.hisData.volume = item->volume;
				tick.openInterest = item->openInterest;
				if ([self addHistoricTick: (HistoricData*)&tick tickType: param->type])
					modify = YES;
			}
		}
		else
		{
			HistoricalDataFormat1 *item;
			for (item in param->historicalDataArray)
			{
				HistoricData tick;
				tick.date = item->date;
				tick.open = item->openPrice;
				tick.high = item->highPrice;
				tick.low = item->lowPrice;
				tick.close = item->closePrice;
				tick.volume = item->volume;
				if ([self addHistoricTick: (HistoricData*)&tick tickType: param->type])
					modify = YES;
			}
		}
	}
	if (modify)
	{
		switch (param->type)
		{
			case '5': fivem_dirty = YES;  break;
			case 'D': day_dirty = YES;  break;
			case 'W': week_dirty = YES; break;
			case 'M': month_dirty = YES; break;
		}
	}
	if (param->retcode == 0)
	{
		[self saveWithTickType: param->type];
		//[self performSelectorOnMainThread:@selector(saveHistoricTicks) withObject:nil waitUntilDone:NO];
		switch (param->type)
		{
			case '5': fivem_islatest = YES;  break;
			case 'D': day_islatest = YES;  break;
			case 'W': week_islatest = YES; break;
			case 'M': month_islatest = YES; break;
		}
	}
	[lock unlock];
}

- (void)saveWithTickType:(UInt8) tickType
{
	NSFileHandle *writeFile;
	NSString *pfFileName;
	int tickCount;
    
	switch (tickType)
	{
		case '5':
		case 'F':
		case 'T':
		case 'S':
			if (!fivem_dirty) return;  break;
		case 'D': if (!day_dirty) return;    break;
		case 'W': if (!week_dirty) return;   break;
		case 'M': if (!month_dirty) return;  break;
		default: return;
	}
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[CodingUtil techLineDataDirectoryPath]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[CodingUtil techLineDataDirectoryPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
	
	pfFileName = [self pfName:tickType];
	[[NSFileManager defaultManager] createFileAtPath:pfFileName contents:nil attributes:nil];
	writeFile = [NSFileHandle fileHandleForWritingAtPath:pfFileName];
	if (writeFile == nil) return;
	
	switch (tickType)
	{
		case '5':
		case 'F':
		case 'T':
		case 'S':
			tickCount = fivem_count;  break;
		case 'D': tickCount = day_count;    break;
		case 'W': tickCount = week_count;   break;
		case 'M': tickCount = month_count;  break;
	}
	for (int i = 0; i < tickCount; i++)
	{
		NSData *fileData;
		if (tickType == '5')
		{
			void *data = [self getHistoricTick: '5' sequenceNo: i];
			if (data == NULL) break;
			fileData = [NSData dataWithBytes: data length: sizeof(Historic5Minute)];
			[writeFile writeData:fileData];
		}
		else if (commodityType == COMMODITY_TYPE_FUTURE)
		{
			void *data = [self getHistoricTick: tickType sequenceNo: i];
			if (data == NULL) break;
			fileData = [NSData dataWithBytes: data length: sizeof(HistoricFuture)];
			[writeFile writeData:fileData];
		}
		else
		{
			void *data = [self getHistoricTick: tickType sequenceNo: i];
			if (data == NULL) break;
			fileData = [NSData dataWithBytes: data length: sizeof(HistoricData)];
			[writeFile writeData:fileData];
		}
	}
	[writeFile closeFile];
	switch (tickType)
	{
		case '5':
		case 'F':
		case 'T':
		case 'S':
			fivem_dirty = NO; break;
		case 'D': day_dirty = NO;   break;
		case 'W': week_dirty = NO;  break;
		case 'M': month_dirty = NO; break;
	}
	return;
}

- (void*)getHistoricTick: (UInt8) tickType sequenceNo: (UInt32) sequenceNo
{
	int cell = sequenceNo / HISTORY_COUNT_PER_CELL;
	int pos  = sequenceNo % HISTORY_COUNT_PER_CELL;
	
	if (tickType == '5')
	{
		if (sequenceNo >= fivem_count) return NULL;
		if (fivem[cell] == NULL) return NULL;
		cell = 0;
		pos = sequenceNo;
		while (pos >= fivem_count_cell[cell] && cell < MAX_HISTORY_CELL_COUNT)
		{
			pos -= fivem_count_cell[cell];
			cell++;
		}
		if (cell >= MAX_HISTORY_CELL_COUNT) return NULL;
		return &fivem[cell][pos];
	}
	switch (tickType)
	{
        case 'D':
            if (sequenceNo >= day_count) return NULL;
            if (day[cell] == NULL) return NULL;
            if (commodityType == COMMODITY_TYPE_FUTURE)
                return &((HistoricFuture*)day[cell])[pos];
            else
                return &((HistoricData*)day[cell])[pos];
        case 'W':
            if (sequenceNo >= week_count) return NULL;
            if (week[cell] == NULL) return NULL;
            if (commodityType == COMMODITY_TYPE_FUTURE)
                return &((HistoricFuture*)week[cell])[pos];
            else
                return &((HistoricData*)week[cell])[pos];
        case 'M':
            if (sequenceNo >= month_count) return NULL;
            if (month[cell] == NULL) return NULL;
            if (commodityType == COMMODITY_TYPE_FUTURE)
                return &((HistoricFuture*)month[cell])[pos];
            else
                return &((HistoricData*)month[cell])[pos];
	}
	return NULL;
}

- (BOOL)isLatestData:(UInt8) type
{
	switch (type)
	{
		case '5':
		case 'F':
		case 'T':
		case 'S':
			return fivem_islatest;
		case 'D': return day_islatest;
		case 'W': return week_islatest;
		case 'M': return month_islatest;
	}
	return NO;
}

- (UInt32)tickCount:(UInt8) tickType
{
	switch (tickType)
	{
		case '5':
			[self todayFiveMK_prepare];
			return fivem_count + todayfivem_count;
		case 'F':
		case 'T':
		case 'S':
			[self todayOtherMK_prepare:tickType];
			return (int)[todayOtherM count];
		case 'D': return day_count;
		case 'W': return week_count;
		case 'M': return month_count;
	}
	return 0;
}

- (void)todayFiveMK_prepare
{
    [lock lock];
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	EquityTick *ticks = [dataModal.portfolioTickBank getEquityTick:identCodeSymbol];
#ifdef LPCB
    FSSnapshot * snapshot = ticks.snapshot_b;
    
    if (ticks == nil || [snapshot.trading_date date16] <= latestFivem || [ticks tickCount] == 0)
	{
		[todayfivem removeAllObjects];
		todayfivem_count = 0;
        [lock unlock];
		return;
	}
#else
    EquitySnapshotDecompressed * snapshot = ticks.snapshot;
    
    if (ticks == nil || snapshot.date <= latestFivem || [ticks tickCount] == 0)
	{
		[todayfivem removeAllObjects];
		todayfivem_count = 0;
        [lock unlock];
		return;
	}
#endif
	
    
	UInt16 time, openTime, closeTime, breakTime, reopenTime, midTime;
//	SInt16 index;
    SInt16 time0;
	double price, volume, prevVolume;
	
	PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:identCodeSymbol];
	MarketInfoItem *pMarket = [[[FSDataModelProc sharedInstance]marketInfo] getMarketInfo: portfolioItem->market_id];  // TSE
	openTime = (pMarket->startTime_1 + 14) / 15 * 15; // round to a multiple of 15
	breakTime = pMarket->endTime_1;
	reopenTime = (pMarket->startTime_2 + 14) / 15 * 15; // round to a multiple of 15
	closeTime = pMarket->endTime_2;
    if ((pMarket->identCode[0] == 'U' && pMarket->identCode[1] == 'S') || (pMarket->identCode[0] == 'T' && pMarket->identCode[1] == 'W') || (pMarket->identCode[0] == 'C' && pMarket->identCode[1] == 'N')) {
        closeTime = breakTime;
        breakTime = 0;
    }else{
        midTime = (breakTime + reopenTime) / 2;
    }
	
	time0 = -MinutePeriod;
	DecompressedHistoric5Minute *pAnalData = nil;
	
	[todayfivem removeAllObjects];
	prevVolume = 0;
	//[ticks lock];
	int tickCount = [ticks tickCount];
	for (int i = 1; i < tickCount; i++)
	{
#ifdef LPCB
        FSTickData *tick = (FSTickData *)[ticks.ticksData objectAtIndex:i];
		if (tick == nil) continue;

        double tickVol = 0.0;
        if(tick.type == FSTickType4){
            tickVol = tick.dealValue.calcValue;
        }else{
            tickVol = tick.accumulated_volume.calcValue;
        }
		if(tickVol >= prevVolume)
		{
			volume = tickVol-prevVolume;
			prevVolume = tickVol;
        }
		else
			continue;
        
		if (breakTime == 0)
			time = RoundMinuteTime([tick.time absoluteMinutesTime]-openTime, openTime, closeTime);
		else
		{
			if ([tick.time absoluteMinutesTime] < midTime)
				time = RoundMinuteTime([tick.time absoluteMinutesTime], openTime, breakTime);
			else
				time = RoundMinuteTime([tick.time absoluteMinutesTime], reopenTime, closeTime);
		}
        if(tick.type == FSTickType4){
            price = tick.indexValue.calcValue;
        }else{
            price = tick.last.calcValue;
        }
		if (time0 != time)
		{
			time0 = time;
			pAnalData = [[DecompressedHistoric5Minute alloc] init];
			pAnalData.date  = [snapshot.trading_date date16];
			pAnalData.time  = time;
			pAnalData.open  = price;
			pAnalData.high  = price;
			pAnalData.low   = price;
			pAnalData.close = price;
			pAnalData.volume   = volume;
			pAnalData.volumeUnit = 0;
			[todayfivem addObject:pAnalData];
		}
		else
		{
			if (pAnalData.high < price) pAnalData.high = price;
			if (pAnalData.low > price)  pAnalData.low = price;
			pAnalData.close = price;
//			if(prevVolumeUnit < pAnalData.volumeUnit)
//			{
//				pAnalData.volume = pAnalData.volume * pow(1000, pAnalData.volumeUnit - prevVolumeUnit);
//				pAnalData.volumeUnit = prevVolumeUnit;
//			}
			pAnalData.volume += volume;
		}
#else
        UInt8 prevVolumeUnit = 0;
        TickDecompressed *tick = [ticks copyTickAtSequenceNo:i];
		if (tick == nil) continue;
		if (prevVolume == 0)
			prevVolumeUnit = tick.volumeUnit;
		double tickVol = tick.volume;
		if(prevVolume == 0)
			prevVolumeUnit = tick.volumeUnit;
		if(tick.volumeUnit < prevVolumeUnit)
		{
			tickVol = tickVol * pow(1000,prevVolumeUnit-tick.volumeUnit);
			prevVolume = prevVolume * pow(1000,prevVolumeUnit-tick.volumeUnit);
			prevVolumeUnit = tick.volumeUnit;
		}
		else
			tickVol = tickVol * pow(1000,tick.volumeUnit - prevVolumeUnit);
		if (tickVol >= prevVolume)
			volume = tickVol - prevVolume;
		else
			volume = tickVol;
		prevVolume = tickVol;
		if (breakTime == 0)
			time = RoundMinuteTime(tick.time, openTime, closeTime);
		else
		{
			if (tick.time < midTime)
				time = RoundMinuteTime(tick.time, openTime, breakTime);
			else
				time = RoundMinuteTime(tick.time, reopenTime, closeTime);
		}
		
		price = tick.price;
		if (time0 != time)
		{
			time0 = time;
			index++ ;
			pAnalData = [[DecompressedHistoric5Minute alloc] init];
			pAnalData.date  = ticks.snapshot.date;
			pAnalData.time  = time;
			pAnalData.open  = price;
			pAnalData.high  = price;
			pAnalData.low   = price;
			pAnalData.close = price;
			pAnalData.volume   = volume;
			pAnalData.volumeUnit = tick.volumeUnit;
			[todayfivem addObject:pAnalData];
		}
		else
		{
			if (pAnalData.high < price) pAnalData.high = price;
			if (pAnalData.low > price)  pAnalData.low = price;
			pAnalData.close = price;
			if(prevVolumeUnit < pAnalData.volumeUnit)
			{
				pAnalData.volume = pAnalData.volume * pow(1000, pAnalData.volumeUnit - prevVolumeUnit);
				pAnalData.volumeUnit = prevVolumeUnit;
			}
			pAnalData.volume += volume;
		}
#endif
		
	}
    //	[ticks unlock];
	todayfivem_count = (int)[todayfivem count];
    [lock unlock];
}

- (void)todayOtherMK_prepare:(UInt8)type		//15~60分線用的
{
    [lock lock];
	int m;
	if(type == 'F') m = 15;
	else if(type == 'T') m = 30;
	else if(type == 'S') m = 60;
	else{
        [lock unlock];
        return;
    }
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	EquityTick *ticks = [dataModal.portfolioTickBank getEquityTick:identCodeSymbol];
	BOOL addFromTick = YES;
    
#ifdef LPCB
    FSSnapshot * snapshot = ticks.snapshot_b;
    if (ticks == nil || [snapshot.trading_date date16] <= latestFivem || [ticks tickCount] == 0)
		addFromTick = NO;
#else
    EquitySnapshotDecompressed * snapshot = ticks.snapshot;
    if (ticks == nil || snapshot.date <= latestFivem || [ticks tickCount] == 0)
		addFromTick = NO;
#endif
	
	
	UInt16 time, openTime, closeTime, breakTime, reopenTime, midTime;
	SInt16 index, time0;
	double price, volume, prevVolume;
	
	PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:identCodeSymbol];
	MarketInfoItem *pMarket = [[[FSDataModelProc sharedInstance]marketInfo] getMarketInfo: portfolioItem->market_id];  // TSE
    if (pMarket != nil) {
        openTime = (pMarket->startTime_1 + 14) / 15 * 15; // round to a multiple of 15
        breakTime = pMarket->endTime_1;
        reopenTime = (pMarket->startTime_2 + 14) / 15 * 15; // round to a multiple of 15
        closeTime = pMarket->endTime_2;
    }else{
        openTime = 0;
        breakTime = 0;;
        reopenTime = 0; // round to a multiple of 15
        closeTime = 0;
    }
    midTime = (breakTime + reopenTime) / 2;
	
	time0 = -m;
	index = 0;
	DecompressedHistoric5Minute *pAnalData = [[DecompressedHistoric5Minute alloc]init];
	
	[todayOtherM removeAllObjects];
    
    
    for(int seq = 1 ; seq <= fivem_count ; seq++)
	{
		void *ptr;
		ptr = [self getHistoricTick:'5' sequenceNo: seq];
		if (ptr == NULL)
			break;
		DecompressedHistoric5Minute *result = [(DecompressedHistoric5Minute *)[DecompressedHistoric5Minute alloc] initWithData: ptr];
		if (breakTime == 0)
			time = RoundMinuteTimeByMinutePeriod(result.time, openTime, closeTime, m);
		else
		{
			int tmpTime = result.time - openTime;
			if (tmpTime < midTime)
				time = RoundMinuteTimeByMinutePeriod(tmpTime, openTime, breakTime, m);
			else
				time = RoundMinuteTimeByMinutePeriod(tmpTime, reopenTime, closeTime, m);
		}
		price = result.close;
		if (time0 != time)
		{
			time0 = time;
			index++ ;
			pAnalData = [[DecompressedHistoric5Minute alloc] init];
			pAnalData.date  = result.date;
			pAnalData.time  = time;
			pAnalData.open  = result.open;
			pAnalData.high  = result.high;
			pAnalData.low   = result.low;
			pAnalData.close = result.close;
			pAnalData.volume   = result.volume;
			pAnalData.volumeUnit = result.volumeUnit;
			[todayOtherM addObject:pAnalData];
		}
		else
		{
			if (pAnalData.high < price) pAnalData.high = price;
			if (pAnalData.low > price)  pAnalData.low = price;
			pAnalData.close = result.close;
			if(result.volumeUnit < pAnalData.volumeUnit)
			{
				pAnalData.volume = pAnalData.volume * pow(1000, (pAnalData.volumeUnit - result.volumeUnit));
				pAnalData.volumeUnit = result.volumeUnit;
			}
			pAnalData.volume += result.volume * pow(1000 , (result.volumeUnit - pAnalData.volumeUnit));
		}
	}
    
    //	[ticks lock];
	prevVolume = 0;
	index = 0;
    
	if(addFromTick)
	{
		int tickCount = [ticks tickCount];
        
#ifdef LPCB
        if ((pMarket->identCode[0] == 'U' && pMarket->identCode[1] == 'S') || (pMarket->identCode[0] == 'T' && pMarket->identCode[1] == 'W') || (pMarket->identCode[0] == 'C' && pMarket->identCode[1] == 'N')) {
            closeTime = breakTime;
            breakTime = 0;
        }
        
        for (int i = 1; i < tickCount; i++)
        {
            FSTickData *tick = (FSTickData *)[ticks.ticksData objectAtIndex:i];
            if (tick == nil) continue;
            
            double tickVol = 0.0;
            if(tick.type == FSTickType4){
                tickVol = tick.dealValue.calcValue;
            }else {
                tickVol = tick.accumulated_volume.calcValue;
            }
            
            if(tickVol >= prevVolume)
            {
                volume = tickVol-prevVolume;
                prevVolume = tickVol;
            }
            else
                continue;
            
            if (breakTime == 0)
                time = RoundMinuteTimeByMinutePeriod([tick.time absoluteMinutesTime]-openTime, openTime, closeTime, m);
            else
            {
                if ([tick.time absoluteMinutesTime] < midTime)
                    time = RoundMinuteTimeByMinutePeriod([tick.time absoluteMinutesTime]-openTime, openTime, breakTime, m);
                else
                    time = RoundMinuteTimeByMinutePeriod([tick.time absoluteMinutesTime]-openTime, reopenTime, closeTime, m);
            }
            if(tick.type == FSTickType4){
                price = tick.indexValue.calcValue;
            }else{
                price = tick.last.calcValue;
            }
            
            if (time0 != time)
            {
                time0 = time;
                pAnalData = [[DecompressedHistoric5Minute alloc] init];
                pAnalData.date  = [snapshot.trading_date date16];
                pAnalData.time  = time;
                pAnalData.open  = price;
                pAnalData.high  = price;
                pAnalData.low   = price;
                pAnalData.close = price;
                pAnalData.volume   = volume;
                pAnalData.volumeUnit = 0;
                [todayOtherM addObject:pAnalData];
            }
            else
            {
                if (pAnalData.high < price) pAnalData.high = price;
                if (pAnalData.low > price)  pAnalData.low = price;
                pAnalData.close = price;
                pAnalData.volume += volume;
            }
            
        }
        
#else
        UInt8 prevVolumeUnit = 0;
        for (int i = 1; i <= tickCount; i++)
		{
			TickDecompressed *tick = [ticks copyTickAtSequenceNo:i];
			if (tick == nil) continue;
			if (prevVolume == 0)
				prevVolumeUnit = tick.volumeUnit;
			double tickVol = tick.volume;
			if(prevVolume == 0)
				prevVolumeUnit = tick.volumeUnit;
			if(tick.volumeUnit < prevVolumeUnit)
			{
				tickVol = tickVol * pow(1000,prevVolumeUnit-tick.volumeUnit);
				prevVolume = prevVolume * pow(1000,prevVolumeUnit-tick.volumeUnit);
				prevVolumeUnit = tick.volumeUnit;
			}
			else
				tickVol = tickVol * pow(1000,tick.volumeUnit - prevVolumeUnit);
			if (tickVol >= prevVolume)
				volume = tickVol - prevVolume;
			else
				volume = tickVol;
			prevVolume = tickVol;
			if (breakTime == 0)
				time = RoundMinuteTimeByMinutePeriod(tick.time, openTime, closeTime, m);
			else
			{
				if (tick.time < midTime)
					time = RoundMinuteTimeByMinutePeriod(tick.time, openTime, breakTime, m);
				else
					time = RoundMinuteTimeByMinutePeriod(tick.time, reopenTime, closeTime, m);
			}
			
			price = tick.price;
			if (time0 != time)
			{
				time0 = time;
				index++ ;
				pAnalData = [[DecompressedHistoric5Minute alloc] init];
				pAnalData.date  = ticks.snapshot.date;
				pAnalData.time  = time;
				pAnalData.open  = price;
				pAnalData.high  = price;
				pAnalData.low   = price;
				pAnalData.close = price;
				pAnalData.volume   = volume;
				pAnalData.volumeUnit = prevVolumeUnit;
				[todayOtherM addObject:pAnalData];
			}
			else
			{
				if (pAnalData.high < price) pAnalData.high = price;
				if (pAnalData.low > price)  pAnalData.low = price;
				pAnalData.close = price;
				if(prevVolumeUnit < pAnalData.volumeUnit)
				{
					pAnalData.volume = pAnalData.volume * pow(1000, pAnalData.volumeUnit - prevVolumeUnit);
					pAnalData.volumeUnit = prevVolumeUnit;
				}
				pAnalData.volume += volume;
			}
		}
#endif
	}
    //	[ticks unlock];
    [lock unlock];
}

- (id)copyHistoricTick: (UInt8) tickType sequenceNo: (UInt32) sequenceNo
{
	void *ptr;
	id result = nil;
	[lock lock];
	if (tickType == '5')
	{
		if (sequenceNo >= fivem_count)
		{
			if (todayfivem == NULL || sequenceNo - fivem_count > todayfivem_count){
                [lock unlock];
                return result;
            }
			DecompressedHistoric5Minute *pAnalData = [todayfivem objectAtIndex:sequenceNo - fivem_count];
			result = pAnalData;
			[lock unlock];
            return result;
		}
		ptr = [self getHistoricTick:tickType sequenceNo: sequenceNo];
		if (ptr == NULL) {
            [lock unlock];
            return result;
        }
		result = [(DecompressedHistoric5Minute *)[DecompressedHistoric5Minute alloc] initWithData: ptr];
	}
	else if(tickType == 'F' || tickType == 'T' || tickType == 'S')
	{
		if(sequenceNo < [todayOtherM count])
			result = [todayOtherM objectAtIndex:sequenceNo];
	}
	else
	{
		ptr = [self getHistoricTick:tickType sequenceNo: sequenceNo];
		if (ptr == NULL) {
            [lock unlock];
            return result;
        }// return nil;
		if (commodityType == COMMODITY_TYPE_FUTURE)
			result = [(DecompressedHistoricFuture *)[DecompressedHistoricFuture alloc] initWithData: ptr];
		else
			result = [(DecompressedHistoricData *)[DecompressedHistoricData alloc] initWithData: ptr];
	}
	[lock unlock];
	return result;
}

- (void)todayOtherMK_finalize
{
	[todayOtherM removeAllObjects];
}
@end
