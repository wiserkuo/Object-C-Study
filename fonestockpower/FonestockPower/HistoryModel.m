//
//  HistoryModel.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "HistoryModel.h"
#import "HistoricDataTypes.h"
#import "HistoryViewController.h"
@interface HistoryModel ()
{
    PortfolioTick *tickBank;
    HistoryViewController *object;
}
@end
@implementation HistoryModel
-(void)getDLine:(NSString *)symbol
{
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    tickBank = dataModal.historicTickBank;
    [tickBank watchTarget:self ForEquity:symbol tickType:'D'];
}

-(void)notifyDataArrive:(NSObject<HistoricTickDataSourceProtocol> *)dataSource
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    HistoricDataAgent *historicData = [[HistoricDataAgent alloc] init];
    char * ident = malloc(2 * sizeof(UInt8));
    ident[0]=[[dataSource getIdenCodeSymbol] characterAtIndex:0];
    ident[1]=[[dataSource getIdenCodeSymbol] characterAtIndex:1];
    NSString *symbol = [[dataSource getIdenCodeSymbol]substringFromIndex:3];
    PortfolioItem *item = [dataModel.portfolioData findInPortfolio:ident Symbol:symbol];
    [historicData updateData:dataSource forPeriod:AnalysisPeriodDay portfolioItem:item];
    BOOL YESNO = NO;
    if([dataSource isLatestData:'D'])
    {
        YESNO = YES;
    }
    
    if(YESNO){
        DecompressedHistoricData *hist;
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        int countNum;
        if([historicData.dataArray count]<300){
            countNum = (int)[historicData.dataArray count];
        }else{
            countNum = 300;
        }
        for(NSInteger i=[historicData.dataArray count]-1; i >=0; i--){
            
            hist = [historicData copyHistoricTick:'D' sequenceNo:(int)i];
            HistoryDrawObject *obj = [[HistoryDrawObject alloc] init];

            obj->lastPrice = hist.close;
            obj->date = hist.date;
            obj->volume = hist.volume * pow(1000, hist.volumeUnit);
            [dataArray addObject:obj];
        }
        [tickBank stopWatch:self ForEquity:[dataSource getIdenCodeSymbol]];
        [object getItemArray:dataArray identCodeSymbol:[NSString stringWithFormat:@"%@", symbol]];
    }
}

-(void)setTarget:(id)target
{
    object = target;

}
@end
@implementation HistoryDrawObject
@end