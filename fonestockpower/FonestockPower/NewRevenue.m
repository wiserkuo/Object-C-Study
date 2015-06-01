//
//  NewRevenue.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/26.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "NewRevenue.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "NewRevenueIn.h"
#import "RevenueOut.h"
#import "NSNumber+Extensions.h"
#import "SKDateUtils.h"
@interface NewRevenue()
@property (nonatomic, strong) NSRecursiveLock *datalock;
@property (nonatomic, strong) NSMutableDictionary *mainDict;
@property (nonatomic, strong) PortfolioItem *portfolioItem;
@property (nonatomic, strong) NSMutableArray *mainArray;
@end


@implementation NewRevenue
- (instancetype)init {
    if (self = [super init]) {
        self.datalock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

-(void)sendAndRead
{
    [self.datalock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:30]];
    
    self.portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%c%c %@ Revenue.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    char dataType = 'S';
    
//    if ([[self.mainDict objectForKey:@"MainArray"] count] > 0) {
//        NSDate *recorDate = [[[[self.mainDict objectForKey:@"MainArray"]firstObject]objectForKey:@"Date"]dayOffset:1];
//        
//        RevenueOut *Revout = [[RevenueOut alloc]initWithDate:[recorDate uint16Value] CommodityNum:self.portfolioItem->commodityNo DataType:dataType];
//        
//        [FSDataModelProc sendData:self WithPacket:Revout];
//    }else{  
        self.mainDict = [[NSMutableDictionary alloc] init];

        UInt16 revRecordDate;
        // today date.
        NSCalendar *userCalendar = [NSCalendar currentCalendar];
        NSDate *today = [NSDate date];
        NSDateComponents *comps = [userCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
        int year = (int)[comps year];
        
        revRecordDate = [CodingUtil makeDate:year - 6 month:1 day:1];
        
        RevenueOut *Revout = [[RevenueOut alloc]initWithDate:revRecordDate CommodityNum:self.portfolioItem->commodityNo DataType:dataType];
        
        [FSDataModelProc sendData:self WithPacket:Revout];

//    }
    [self.datalock unlock];
}


-(void)NewRevenueDataCallBack:(NewRevenueIn *)data
{
    [self.datalock lock];
    if ([data -> dataArray count] > 0) {
        self.mainArray = [[NSMutableArray alloc]init];
        
        if(data->dataType == 'M'){
            for(int i = 0; i <[data->dataArray count] && i < 24 ; i++){
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                RevenueObject *object = [[RevenueObject alloc] init];
                RevenueObject *beforeObject = [[RevenueObject alloc] init];
                object = [data->dataArray objectAtIndex:i];
                if(i+11 <= [data->dataArray count]){
                    beforeObject = [data->dataArray objectAtIndex:i+12];
                    [dict setObject:[NSNumber numberWithDouble:[CodingUtil getRevenueTAValue:beforeObject->revenue Uint:beforeObject->revenueUnit]] forKey:@"RevenueYearAgo"];
                    [dict setObject:[NSNumber numberWithDouble:[CodingUtil getRevenueTAValue:beforeObject->accumulatedRevenue Uint:beforeObject->accumulatedRevenueUnit]] forKey:@"AccumulatedRevenueYearAgo"];
                    [dict setObject:[NSNumber numberWithDouble:[CodingUtil getRevenueTAValue:beforeObject->accumulatedAchieveRate Uint:beforeObject->accumulatedAchieveRateUnit]] forKey:@"AccumulatedAchieveRateYearAgo"];
                    [dict setObject:[NSNumber numberWithDouble:[CodingUtil getRevenueTAValue:beforeObject->mergedRevenue Uint:beforeObject->mergedRevenueUnit]] forKey:@"MergedRevenueYearAgo"];
                    [dict setObject:[NSNumber numberWithDouble:[CodingUtil getRevenueTAValue:beforeObject->accumulatedMergedRevenue Uint:beforeObject->accumulatedMergedRevenueUnit]] forKey:@"AccumulatedMergedRevenueYearAgo"];

                    //合併營收成長率
                    if(beforeObject->mergedRevenue == 0.00){
                        [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"MergedRevenueYoY"];
                    }else{
                        [dict setObject:[NSNumber numberWithDouble:(object->mergedRevenue - beforeObject->mergedRevenue) / beforeObject->mergedRevenue * 100] forKey:@"MergedRevenueYoY"];
                    }
                    
                    //累計合併營收成長率
                    if(beforeObject->accumulatedMergedRevenue == 0.00){
                        [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"AccumulatedMergedRevenueYoY"];
                    }else{
                        [dict setObject:[NSNumber numberWithDouble:(object->accumulatedMergedRevenue - beforeObject->accumulatedMergedRevenue) / beforeObject->accumulatedMergedRevenue * 100] forKey:@"AccumulatedMergedRevenueYoY"];
                    }
                    
                    //營收成長率
                    if(beforeObject->revenue == 0.00){
                        [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"RevenueYoY"];
                    }else{
                        [dict setObject:[NSNumber numberWithDouble:(object->revenue - beforeObject->revenue) / beforeObject->revenue * 100] forKey:@"RevenueYoY"];
                    }
                    
                    //累計營收成長率
                    if(beforeObject->accumulatedRevenue == 0.00){
                        [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"AccumulatedRevenueYoY"];
                    }else{
                        [dict setObject:[NSNumber numberWithDouble:(object->accumulatedRevenue - beforeObject->accumulatedRevenue) / beforeObject->accumulatedRevenue * 100] forKey:@"AccumulatedRevenueYoY"];
                    }
                }else{
                    [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"RevenueYearAgo"];
                    [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"AccumulatedRevenueYearAgo"];
                    [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"AccumulatedAchieveRateYearAgo"];
                    [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"MergedRevenueYearAgo"];
                    [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"AccumulatedMergedRevenueYearAgo"];
                    //合併營收成長率
                    [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"MergedRevenueYoY"];
                    //累計合併營收成長率
                    [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"AccumulatedMergedRevenueYoY"];
                    //營收成長率
                    [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"RevenueYoY"];
                    //累計營收成長率
                    [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"AccumulatedRevenueYoY"];
                }
                if(i+1 <[data->dataArray count]){
                    //月增率
                    beforeObject = [data->dataArray objectAtIndex:i+1];
                    [dict setObject:[NSNumber numberWithDouble:(object->mergedRevenue - beforeObject->mergedRevenue) / beforeObject->mergedRevenue * 100] forKey:@"MoM"];
                }else{
                    [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"MoM"];
                }
                [dict setObject:[[NSNumber numberWithUnsignedInt:object->date]uint16ToDate] forKey:@"Date"];
                [dict setObject:[NSNumber numberWithDouble:[CodingUtil getRevenueTAValue:object->revenue Uint:object->revenueUnit]] forKey:@"Revenue"];
                [dict setObject:[NSNumber numberWithDouble:[CodingUtil getRevenueTAValue:object->accumulatedRevenue Uint:object->accumulatedRevenueUnit]] forKey:@"AccumulatedRevenue"];
                [dict setObject:[NSNumber numberWithDouble:[CodingUtil getRevenueTAValue:object->accumulatedAchieveRate Uint:object->accumulatedAchieveRateUnit]] forKey:@"AccumulatedAchieveRate"];
                [dict setObject:[NSNumber numberWithDouble:[CodingUtil getRevenueTAValue:object->mergedRevenue Uint:object->mergedRevenueUnit]] forKey:@"MergedRevenue"];
                [dict setObject:[NSNumber numberWithDouble:[CodingUtil getRevenueTAValue:object->accumulatedMergedRevenue Uint:object->accumulatedMergedRevenueUnit]] forKey:@"AccumulatedMergedRevenue"];
                [self.mainArray addObject:dict];

            }
        }else if(data->dataType == 'Q'){
            for(int i = 0; i <[data->dataArray count] && i < 12 ; i++){
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                RevenueObject *object = [[RevenueObject alloc] init];
                RevenueObject *beforeObject = [[RevenueObject alloc] init];
                object = [data->dataArray objectAtIndex:i];
                
                if(i+4 < [data->dataArray count]){
                    beforeObject = [data->dataArray objectAtIndex:i+4];
                    if(![[[FSFonestock sharedInstance].appId substringToIndex:2] isEqualToString:@"cn"]){
                        [dict setObject:[NSNumber numberWithDouble:[CodingUtil getRevenueTAValue:beforeObject->revenue Uint:beforeObject->revenueUnit]] forKey:@"RevenueYearAgo"];
                    }

                    [dict setObject:[NSNumber numberWithDouble:[CodingUtil getRevenueTAValue:beforeObject->accumulatedRevenue Uint:beforeObject->accumulatedRevenueUnit]] forKey:@"AccumulatedRevenueYearAgo"];
                    //營收成長率
                    if(beforeObject->revenue == 0.00){
                        [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"RevenueYoY"];
                    }else{
                        [dict setObject:[NSNumber numberWithDouble:(object->revenue - beforeObject->revenue) / beforeObject->revenue * 100] forKey:@"RevenueYoY"];
                    }
                    //累計營收成長率
                    if(beforeObject->accumulatedRevenue == 0.00){
                        [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"AccumulatedRevenueYoY"];
                    }else{
                        [dict setObject:[NSNumber numberWithDouble:(object->accumulatedRevenue - beforeObject->accumulatedRevenue) / beforeObject->accumulatedRevenue * 100] forKey:@"AccumulatedRevenueYoY"];
                    }
                }else{
                    [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"RevenueYearAgo"];
                    [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"AccumulatedRevenueYearAgo"];
                    //營收成長率
                    [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"RevenueYoY"];
                    //累計營收成長率
                    [dict setObject:[NSNumber numberWithDouble:0.00] forKey:@"AccumulatedRevenueYoY"];
                }
                if([[[FSFonestock sharedInstance].appId substringToIndex:2] isEqualToString:@"cn"]){
                    RevenueObject *beforeRevenObject = [[RevenueObject alloc] init];
                    RevenueObject *revenYearAgoObject = [[RevenueObject alloc] init];
                    beforeRevenObject = [data->dataArray objectAtIndex:i+1];
                    revenYearAgoObject = [data->dataArray objectAtIndex:i+5];
                    double revenue = 0.0;
                    double beforeRevenue = 0.0;
                    
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"MM"];
                    NSNumber *numberDate1 = [NSNumber numberWithInt:object->date];
                    
                    int date1 = [[formatter stringFromDate:[numberDate1 uint16ToDate]] intValue];
                    
                    if (date1 >= 1 && date1 <= 3) {
                        revenue = [CodingUtil getRevenueTAValue:object->accumulatedRevenue Uint:object->accumulatedRevenueUnit];
                        beforeRevenue = [CodingUtil getRevenueTAValue:beforeObject->accumulatedRevenue Uint:beforeObject->accumulatedRevenueUnit];
                    }
                    else {
                        revenue = [CodingUtil getRevenueTAValue:object->accumulatedRevenue Uint:object->accumulatedRevenueUnit] - [CodingUtil getRevenueTAValue:beforeRevenObject->accumulatedRevenue Uint:beforeRevenObject->accumulatedRevenueUnit];
                        beforeRevenue= [CodingUtil getRevenueTAValue:beforeObject->accumulatedRevenue Uint:beforeObject->accumulatedRevenueUnit] - [CodingUtil getRevenueTAValue:revenYearAgoObject->accumulatedRevenue Uint:revenYearAgoObject->accumulatedRevenueUnit];
                    }
                    
                    
                    [dict setObject:[NSNumber numberWithDouble:revenue] forKey:@"Revenue"];
                    [dict setObject:[NSNumber numberWithDouble:beforeRevenue] forKey:@"RevenueYearAgo"];
                    [dict setObject:[NSNumber numberWithDouble:(revenue - beforeRevenue) / beforeRevenue * 100]forKey:@"RevenueYoY"];
                }else{
                    [dict setObject:[NSNumber numberWithDouble:[CodingUtil getRevenueTAValue:object->revenue Uint:object->revenueUnit]] forKey:@"Revenue"];
                }
                [dict setObject:[[NSNumber numberWithUnsignedInt:object->date]uint16ToDate] forKey:@"Date"];
                [dict setObject:[NSNumber numberWithDouble:[CodingUtil getRevenueTAValue:object->accumulatedRevenue Uint:object->accumulatedRevenueUnit]] forKey:@"AccumulatedRevenue"];

                [self.mainArray addObject:dict];
            }
        }

        [self.mainDict setObject:self.mainArray forKey:@"MainArray"];
        [self saveToFile];
    }
    
    if ([self.delegate respondsToSelector:@selector(NewRevenueNotifyData:)]) {
        [self.delegate NewRevenueNotifyData:[self.mainDict objectForKey:@"MainArray"]];
    }
    if ([self.chartViewDelegate respondsToSelector:@selector(NewRevenueChartViewNotifyData:)]) {
        [self.chartViewDelegate NewRevenueChartViewNotifyData:[self.mainDict objectForKey:@"MainArray"]];
    }
    
    [self.datalock unlock];
}

- (void)saveToFile {
	[self.datalock lock];
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%c%c %@ Revenue.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
	BOOL success = [self.mainDict writeToFile:path atomically:YES];
	if(!success) NSLog(@"Revenue error!!");
	[self.datalock unlock];
}
@end
