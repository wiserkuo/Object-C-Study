//
//  StockHolderMeeting.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "StockHolderMeeting.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "StockHolderMeetingIn.h"
#import "StockHolderMeetingOut.h"
#import "HistoricalDividendIn.h"
#import "HistoricalDividendOut.h"
#import "HistoricalEPSIn.h"
#import "HistoricalEPSOut.h"

@interface StockHolderMeeting()
@property (nonatomic, strong) NSRecursiveLock *datalock;
@property (nonatomic, strong) NSMutableDictionary *mainDict;
@property (nonatomic, strong) NSMutableDictionary *epsDict;
@property (nonatomic, strong) NSMutableDictionary *hisDict;
@property (nonatomic, strong) PortfolioItem *portfolioItem;
@end


@implementation StockHolderMeeting
- (instancetype)init {
    if (self = [super init]) {
        self.datalock = [[NSRecursiveLock alloc] init];
    }
    return self;
}
- (NSDictionary *)getDictData {
    return self.mainDict;
}

-(void)getTypeDate:(int)typeNumber
{
    //[self syncStockholderMetting:typeNumber];
}

- (void)sendAndRead {
    [self.datalock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:30]];
    
    self.portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%c%c %@ StockHolderMeeting.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"YYYY-MM-dd"];
    NSString *dateStr = [formatter1 stringFromDate:date];
    
    if ([[self.mainDict objectForKey:@"Date"] isEqualToString:dateStr]) {
        if ([self.delegate respondsToSelector:@selector(StockHolderMeetingNotifyData:)]) {
            [self.delegate performSelectorOnMainThread:@selector(StockHolderMeetingNotifyData:) withObject:self.mainDict waitUntilDone:NO];
        }
    } else {
        self.mainDict = [[NSMutableDictionary alloc] init];
        sendNumber = 1;
        [self syncStockholderMeeting];
    }
    
    NSString *epsPath = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%c%c %@ StockHolderMeetingEPS.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
    UInt16 bDate;
	bDate = [CodingUtil makeDate:1960 month:1 day:1];
    NSDateFormatter *nowYearDateFormat = [[NSDateFormatter alloc] init];
    [nowYearDateFormat setDateFormat:@"yyyy"];
    NSDate *nowDate = [[NSDate alloc] init];
    int now = [(NSNumber *)[nowYearDateFormat stringFromDate:nowDate] intValue];
    UInt16 eDate;
    eDate = [CodingUtil makeDate:now month:1 day:1];
    
    self.epsDict = [NSMutableDictionary dictionaryWithContentsOfFile:epsPath];
    if ([[self.epsDict objectForKey:@"Date"] isEqualToString:dateStr]) {
        if ([self.delegate respondsToSelector:@selector(EPSNotifyData:)]) {
            [self.delegate performSelectorOnMainThread:@selector(EPSNotifyData:) withObject:self.epsDict waitUntilDone:NO];
        }
    } else {
        self.epsDict = [[NSMutableDictionary alloc] init];
        HistoricalEPSOut *epsOut = [[HistoricalEPSOut alloc]initWithStartDate:bDate EndDate:eDate CommodityNum:self.portfolioItem->commodityNo EPSType:1];
        [FSDataModelProc sendData:self WithPacket:epsOut];
    }
    NSString *hisPath = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%c%c %@ StockHolderMeetingHis.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    self.hisDict = [NSMutableDictionary dictionaryWithContentsOfFile:hisPath];
    

    if ([[self.hisDict objectForKey:@"Date"] isEqualToString:dateStr]) {
        if ([self.delegate respondsToSelector:@selector(HisNotifyData:)]) {
            [self.delegate performSelectorOnMainThread:@selector(HisNotifyData:) withObject:self.hisDict waitUntilDone:NO];
        }
    } else {
        NSUInteger componentFlags = NSYearCalendarUnit;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:componentFlags fromDate:[[NSDate alloc]init]];
        int year = (int)[components year];
        UInt16 end;
        end = [CodingUtil makeDate:year month:1 day:1];
        UInt16 start;
        start = [CodingUtil makeDate:year-10 month:1 day:1];
        self.hisDict = [[NSMutableDictionary alloc] init];
        HistoricalDividendOut *hisOut = [[HistoricalDividendOut alloc]initWithStartDate:start EndDate:end CommodityNum:self.portfolioItem->commodityNo];
        [FSDataModelProc sendData:self WithPacket:hisOut];
    }

    [self.datalock unlock];
}

-(void)syncStockholderMeeting{
    UInt16 sDate;
	sDate = [CodingUtil makeDate:1960 month:1 day:1];
	StockHolderMeetingOut *SMOut = [[StockHolderMeetingOut alloc]
                                       initWithCommodityNum:self.portfolioItem->commodityNo
                                       QueryType:sendNumber
                                       RecordDate:sDate];
    [FSDataModelProc sendData:self WithPacket:SMOut];
}

-(void)sendHistoricalDividend
{
    UInt16 bDate;
	bDate = [CodingUtil makeDate:1960 month:1 day:1];
    NSDateFormatter *nowYearDateFormat = [[NSDateFormatter alloc] init];
    [nowYearDateFormat setDateFormat:@"yyyy"];
    NSDate *nowDate = [[NSDate alloc] init];
    int now = [(NSNumber *)[nowYearDateFormat stringFromDate:nowDate] intValue];
    UInt16 eDate;
    eDate = [CodingUtil makeDate:now month:1 day:1];
    HistoricalDividendOut *hisOut = [[HistoricalDividendOut alloc]initWithStartDate:bDate EndDate:eDate CommodityNum:self.portfolioItem->commodityNo];
    [FSDataModelProc sendData:self WithPacket:hisOut];
}

- (void)HistoricalDividendDataCallBack:(HistoricalDividendIn *)data
{
    [self.datalock lock];
    [self.hisDict setObject:[NSNumber numberWithInteger:[data->historicalDividendArray count]] forKey:@"HistoricalCount"];
 
    for (int i = 0;i<[data->historicalDividendArray count];i++){
        HistoricalDividendParam * historicalData = [data->historicalDividendArray objectAtIndex:i];
        NSDateFormatter *newDateFormat = [[NSDateFormatter alloc] init];
        [newDateFormat setDateFormat:@"yyyy"];
        NSString * dateStr =[newDateFormat stringFromDate:[[NSNumber numberWithUnsignedInt:historicalData->date]uint16ToDate]];
        int yearInt = [dateStr intValue];

        [self.hisDict setObject:[NSString stringWithFormat:@"%i",yearInt-1] forKey:[NSString stringWithFormat:@"Year%i",i]];
//        [self.hisDict setObject:[NSString stringWithFormat:@"%i",yearInt] forKey:[NSString stringWithFormat:@"Year%i",i]];
        [self.hisDict setObject:historicalData->emDiv forKey:[NSString stringWithFormat:@"EmDiv%i",i]];
        [self.hisDict setObject:historicalData->capDiv forKey:[NSString stringWithFormat:@"emDiv%i",i]];
        if([historicalData->cshDiv isEqualToString:@"----"]){
            [self.hisDict setObject:@"----" forKey:[NSString stringWithFormat:@"cshDiv%i", i]];
        }else{
            double cshDiv = floor([historicalData->cshDiv doubleValue] *1000) / 1000;
            if (cshDiv > 100) {
                [self.hisDict setObject:[NSString stringWithFormat:@"%.1f", cshDiv] forKey:[NSString stringWithFormat:@"cshDiv%i",i]];
            }else if (cshDiv > 10){
                [self.hisDict setObject:[NSString stringWithFormat:@"%.2f", cshDiv] forKey:[NSString stringWithFormat:@"cshDiv%i",i]];
            }else{
                [self.hisDict setObject:[NSString stringWithFormat:@"%.3f", cshDiv] forKey:[NSString stringWithFormat:@"cshDiv%i",i]];
            }
        }
    }
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"YYYY-MM-dd"];
    NSString *dateStr = [formatter1 stringFromDate:date];
    [self.hisDict setObject:dateStr forKey:@"Date"];
    [self saveToHisFile];
    
    if ([self.delegate respondsToSelector:@selector(HisNotifyData:)]) {
        [self.delegate HisNotifyData:self.hisDict];
    }
    
    [self.datalock unlock];
}

- (void)stockHolderMeetingDataCallBack:(StockHolderMeetingIn *)data
{
    [self.datalock lock];
    StockHolderMeetingData * data1 = data->stockHolderObject;
    if(data1->DataDate!=0){
        [self.mainDict setObject:[NSNumber numberWithUnsignedInt:data1->DataDate] forKey:[NSString stringWithFormat:@"Type%dDataDate",data->dataType]];
        [self.mainDict setObject:[self getDateStr:[[NSNumber numberWithUnsignedInt:data1->meetingDate]uint16ToDate]] forKey:[NSString stringWithFormat:@"Type%dMeetingDate",data->dataType]];
        [self.mainDict setObject:[self getDateStr:[[NSNumber numberWithUnsignedInt:data1->lastTranDate]uint16ToDate]] forKey:[NSString stringWithFormat:@"Type%dLastTranDate",data->dataType]];
        [self.mainDict setObject:[self getDateStr:[[NSNumber numberWithUnsignedInt:data1->stopTranDate]uint16ToDate]] forKey:[NSString stringWithFormat:@"Type%dStopTranDate",data->dataType]];
        [self.mainDict setObject:[self getDateStr:[[NSNumber numberWithUnsignedInt:data1->stopShrDateBegin]uint16ToDate]] forKey:[NSString stringWithFormat:@"Type%dStopShrDateBegin",data->dataType]];
        [self.mainDict setObject:[self getDateStr:[[NSNumber numberWithUnsignedInt:data1->stopShrDateEnd]uint16ToDate]] forKey:[NSString stringWithFormat:@"Type%dStopShrDateEnd",data->dataType]];
        [self.mainDict setObject:[self getDateStr:[[NSNumber numberWithUnsignedInt:data1->retShrDate]uint16ToDate]] forKey:[NSString stringWithFormat:@"Type%dRetShrDate",data->dataType]];
        [self.mainDict setObject:[self getDateStr:[[NSNumber numberWithUnsignedInt:data1->stopAmntDateBegin]uint16ToDate]] forKey:[NSString stringWithFormat:@"Type%dStopAmntDateBegin",data->dataType]];
        [self.mainDict setObject:[self getDateStr:[[NSNumber numberWithUnsignedInt:data1->stopAmntDateEnd]uint16ToDate] ]forKey:[NSString stringWithFormat:@"Type%dStopAmntDateEnd",data->dataType]];
        
        if (data->dataType == 1) {
            [self.mainDict setObject:[data1->ernDiv format] forKey:@"ErnDiv"];
            [self.mainDict setObject:[data1->capDiv format] forKey:@"CapDiv"];
            [self.mainDict setObject:[data1->cashDiv format]forKey:@"CashDiv"];
            if (![data1->boardReElection isEqualToString:@""]) {
                [self.mainDict setObject:data1->boardReElection forKey:@"BoardReElection"];
            }else{
                [self.mainDict setObject:@"----" forKey:@"BoardReElection"];
            }
        }else if(data->dataType == 2){
            [self.mainDict setObject:[self getDateStr:[[NSNumber numberWithUnsignedInt:data1->stockDividendReleaseDate]uint16ToDate]] forKey:@"StockDividendReleaseDate"];
            
        }else if(data->dataType == 3){
            [self.mainDict setObject:[self getDateStr:[[NSNumber numberWithUnsignedInt:data1->cashDividendReleaseDate]uint16ToDate]] forKey:@"CashDividendReleaseDate"];
            
        }else if(data->dataType == 4){
            [self.mainDict setObject:[self getDateStr:[[NSNumber numberWithUnsignedInt:data1->cashAndStockReleaseDate]uint16ToDate]] forKey:@"CashAndStockReleaseDate"];
            
            int capIncAmntValue = (int)data1->capIncAmnt.value / 100000000;
            [self.mainDict setObject:[NSString stringWithFormat:@"%d",capIncAmntValue] forKey:@"CapIncAmnt"];
            
            [self.mainDict setObject:[data1->capIncStkPrice format] forKey:@"CapIncStkPrice"];
            [self.mainDict setObject:[data1->capIncStockRatio format] forKey:@"CapIncStockRatio"];
            
            int newCapitalValue = (int)data1->newCapital.value / 100000000;
            [self.mainDict setObject:[NSString stringWithFormat:@"%d(億)",newCapitalValue] forKey:@"NewCapital"];
        }
    }else{
        [self.mainDict setObject:@"----" forKey:[NSString stringWithFormat:@"Type%dMeetingDate",data->dataType]];
        [self.mainDict setObject:@"----" forKey:[NSString stringWithFormat:@"Type%dLastTranDate",data->dataType]];
        [self.mainDict setObject:@"----" forKey:[NSString stringWithFormat:@"Type%dStopTranDate",data->dataType]];
        [self.mainDict setObject:@"----" forKey:[NSString stringWithFormat:@"Type%dStopShrDateBegin",data->dataType]];
        [self.mainDict setObject:@"----" forKey:[NSString stringWithFormat:@"Type%dStopShrDateEnd",data->dataType]];
        [self.mainDict setObject:@"----" forKey:[NSString stringWithFormat:@"Type%dRetShrDate",data->dataType]];
        [self.mainDict setObject:@"----" forKey:[NSString stringWithFormat:@"Type%dStopAmntDateBegin",data->dataType]];
        [self.mainDict setObject:@"----" forKey:[NSString stringWithFormat:@"Type%dStopAmntDateEnd",data->dataType]];
        
        if (data->dataType == 1) {
            [self.mainDict setObject:@"----" forKey:@"ErnDiv"];
            [self.mainDict setObject:@"----" forKey:@"CapDiv"];
            [self.mainDict setObject:@"----" forKey:@"CashDiv"];
            [self.mainDict setObject:@"----" forKey:@"BoardReElection"];
            
        }else if(data->dataType == 2){
            [self.mainDict setObject:@"----" forKey:@"StockDividendReleaseDate"];
            
        }else if(data->dataType == 3){
            [self.mainDict setObject:@"----" forKey:@"CashDividendReleaseDate"];
            
        }else if(data->dataType == 4){
            [self.mainDict setObject:@"----" forKey:@"CashAndStockReleaseDate"];
            [self.mainDict setObject:@"----" forKey:@"CapIncAmnt"];
            [self.mainDict setObject:@"----" forKey:@"CapIncStkPrice"];
            [self.mainDict setObject:@"----" forKey:@"CapIncStockRatio"];
            [self.mainDict setObject:@"----" forKey:@"NewCapital"];
        }
    }
    if(data->dataType == 5){
        NSDateFormatter *formatterYear = [[NSDateFormatter alloc] init];
        [formatterYear setDateFormat:@"YYYY"];
        NSString *year = [NSString stringWithFormat:@"%d", [[formatterYear stringFromDate:[[NSNumber numberWithInt:data1->taxDate]uint16ToDate]]intValue]-1911];
        [self.mainDict setObject:year forKey:@"TaxDate"];
        [self.mainDict setObject:[NSString stringWithFormat:@"%.2f",data1->taxCredit.calcValue] forKey:@"TaxCredit"];
    }
    
    sendNumber ++;
    
    if(sendNumber <=5){
        [self.datalock unlock];
        [self syncStockholderMeeting];
    }else{
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
        [formatter1 setDateFormat:@"YYYY-MM-dd"];
        NSString *dateStr = [formatter1 stringFromDate:date];
        [self.mainDict setObject:dateStr forKey:@"Date"];
        [self saveToFile];
        if ([self.delegate respondsToSelector:@selector(StockHolderMeetingNotifyData:)]) {
            [self.delegate StockHolderMeetingNotifyData:self.mainDict];
        }
    
        [self.datalock unlock];
    }
    
}
-(void)HistoricalEPSCallBack:(FSHistoricalEPSIn*)data{
    [self.datalock lock];
    [self.epsDict setObject:[NSNumber numberWithInteger:[data->historicalEPSArray count]] forKey:@"EPSCount"];
    
    for (int i = 0;i<[data->historicalEPSArray count];i++){
        NewHistoricalEPSParam * epsData = [data->historicalEPSArray objectAtIndex:i];
        [self.epsDict setObject:[NSString stringWithFormat:@"%.2f",epsData->epsValue] forKey:[NSString stringWithFormat:@"eps%i",i]];
        
        [self.epsDict setObject:[NSString stringWithFormat:@"%d",epsData->date] forKey:[NSString stringWithFormat:@"epsDate%i",i]];
    }
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"YYYY-MM-dd"];
    NSString *dateStr = [formatter1 stringFromDate:date];
    [self.epsDict setObject:dateStr forKey:@"Date"];
    [self saveToEPSFile];
    
    if ([self.delegate respondsToSelector:@selector(EPSNotifyData:)]) {
        [self.delegate EPSNotifyData:self.epsDict];
    }
    
    [self.datalock unlock];
}


- (void)saveToFile {
	[self.datalock lock];
    
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%c%c %@ StockHolderMeeting.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
	BOOL success = [self.mainDict writeToFile:path atomically:YES];
	if(!success) NSLog(@"StockholderMeeting wirte error!!");
	[self.datalock unlock];
}

- (void)saveToEPSFile {
	[self.datalock lock];
    
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%c%c %@ StockHolderMeetingEPS.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
	BOOL success = [self.epsDict writeToFile:path atomically:YES];
	if(!success) NSLog(@"StockholderMeeting wirte error!!");
	[self.datalock unlock];
}

- (void)saveToHisFile {
	[self.datalock lock];
    
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%c%c %@ StockHolderMeetingHis.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
	BOOL success = [self.hisDict writeToFile:path atomically:YES];
	if(!success) NSLog(@"StockholderMeeting wirte error!!");
	[self.datalock unlock];
}

-(NSString *)getDateStr:(NSDate*)date
{
    NSDateFormatter *wrongFormatter = [[NSDateFormatter alloc]init];
    [wrongFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *wrongDate = [wrongFormatter dateFromString:@"1959-11-30 08:00:00"];
    
    if ([date isEqualToDate:wrongDate]) {
        return @"----";
    }else{
        NSDateFormatter *yearFormat = [[NSDateFormatter alloc] init];
        [yearFormat setDateFormat:@"yyyy"];
        int year = [[yearFormat stringFromDate:date]intValue];
        year-=1911;
        
        NSDateFormatter *monthFormat = [[NSDateFormatter alloc] init];
        [monthFormat setDateFormat:@"MM"];
        NSString *month = [monthFormat stringFromDate:date];
        
        NSDateFormatter *dayFormat = [[NSDateFormatter alloc] init];
        [dayFormat setDateFormat:@"dd"];
        NSString *day = [dayFormat stringFromDate:date];
        
        return [NSString stringWithFormat:@"%d/%@/%@",year,month,day];
    }
}

@end