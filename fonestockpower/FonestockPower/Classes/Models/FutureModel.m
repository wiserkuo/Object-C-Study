//
//  FutureModel.m
//  WirtsLeg
//
//  Created by Neil on 13/9/30.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FutureModel.h"
#import "FMDatabaseQueue.h"

@implementation FutureModel
@synthesize notifyObj;

-(void)setTarget:(id)obj{
    notifyObj = obj;
}

-(void)setGroupTarget:(id)obj{
    groupNotifyObj = obj;
}

-(id)init{
    _singleVolumeDictionary = [[NSMutableDictionary alloc]init];
    return self;
}

-(void)updateSnapshotWithArray:(NSMutableArray *)array{
    

    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];

    [dataModal.portfolioData addWatchListItemByIdentSymbolArray:array];
    [notifyObj performSelectorOnMainThread:@selector(notifyDataArrive) withObject:nil waitUntilDone:NO];
    
}


-(void)searchSnapshotWithArray:(NSMutableArray *)array{
    NSMutableArray * rowArray = [array objectAtIndex:0];
    NSMutableArray * idArray =[array objectAtIndex:1];
    NSMutableDictionary * currentPriceDictionary = [[NSMutableDictionary alloc]init];
    NSMutableDictionary * bidPriceDictionary = [[NSMutableDictionary alloc]init];
    NSMutableDictionary * askPriceDictionary = [[NSMutableDictionary alloc]init];
    NSMutableDictionary * highestPriceDictionary = [[NSMutableDictionary alloc]init];
    NSMutableDictionary * lowestPriceDictionary = [[NSMutableDictionary alloc]init];
    NSMutableDictionary * chgDictionary = [[NSMutableDictionary alloc]init];
    NSMutableDictionary * p_chgDictionary = [[NSMutableDictionary alloc]init];
    NSMutableDictionary * VolumeDictionary = [[NSMutableDictionary alloc]init];
    NSMutableDictionary * accumulatedVolumeDictionary = [[NSMutableDictionary alloc]init];
    NSMutableDictionary * referencePriceDictionary = [[NSMutableDictionary alloc]init];
    NSMutableDictionary * statusDictionary = [[NSMutableDictionary alloc]init];
    NSMutableDictionary * topPriceDictionary = [[NSMutableDictionary alloc]init];
    NSMutableDictionary * bottomPriceDictionary = [[NSMutableDictionary alloc]init];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    tickBank = dataModal.portfolioTickBank;
    for (int i=0;i<[idArray count];i++) {
        PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:[idArray objectAtIndex:i]];
        if(portfolioItem)
        {
            EquitySnapshotDecompressed *mySnapshot = [tickBank getSnapshot:portfolioItem->commodityNo];
            
            if(mySnapshot){
                [statusDictionary setObject:[CodingUtil ConvertPriceValueToString:mySnapshot.statusOfEquity] forKey:[rowArray objectAtIndex:i]];
                
                [referencePriceDictionary setObject:[CodingUtil ConvertPriceValueToString:mySnapshot.referencePrice] forKey:[rowArray objectAtIndex:i]];
                
                [topPriceDictionary setObject:[CodingUtil ConvertPriceValueToString:mySnapshot.ceilingPrice] forKey:[rowArray objectAtIndex:i]];
                
                [bottomPriceDictionary setObject:[CodingUtil ConvertPriceValueToString:mySnapshot.floorPrice] forKey:[rowArray objectAtIndex:i]];
                
                //買進
                if(mySnapshot.bid == 0){
                    [bidPriceDictionary setObject:@"----" forKey:[rowArray objectAtIndex:i]];
                }else{
                    [bidPriceDictionary setObject:[CodingUtil ConvertPriceValueToString:mySnapshot.bid] forKey:[rowArray objectAtIndex:i]];
                }
                //賣出
                if(mySnapshot.ask == 0){
                    [askPriceDictionary setObject:@"----" forKey:[rowArray objectAtIndex:i]];
                }else{
                    [askPriceDictionary setObject:[CodingUtil ConvertPriceValueToString:mySnapshot.ask] forKey:[rowArray objectAtIndex:i]];
                }
                    //成交價
                if(mySnapshot.currentPrice == 0){
                    [currentPriceDictionary setObject:@"----" forKey:[rowArray objectAtIndex:i]];
                }else{
                    [currentPriceDictionary setObject:[CodingUtil ConvertPriceValueToString:mySnapshot.currentPrice] forKey:[rowArray objectAtIndex:i]];
                }
                    //最高
                if(mySnapshot.highestPrice == 0){
                    [highestPriceDictionary setObject:@"----" forKey:[rowArray objectAtIndex:i]];
                }else{
                    [highestPriceDictionary setObject:[CodingUtil ConvertPriceValueToString:mySnapshot.highestPrice] forKey:[rowArray objectAtIndex:i]];
                }
                    //最低
                if(mySnapshot.lowestPrice == 0){
                    [lowestPriceDictionary setObject:@"----" forKey:[rowArray objectAtIndex:i]];
                }else{
                    [lowestPriceDictionary setObject:[CodingUtil ConvertPriceValueToString:mySnapshot.lowestPrice] forKey:[rowArray objectAtIndex:i]];
                }
                    //漲跌
                if(mySnapshot.currentPrice != 0 && mySnapshot.referencePrice !=0){
                    double chg = mySnapshot.currentPrice - mySnapshot.referencePrice;
                    
                    [chgDictionary setObject:[NSString stringWithFormat:@"%.2f",chg] forKey:[rowArray objectAtIndex:i]];
                }else{
                    [chgDictionary setObject:@"----" forKey:[rowArray objectAtIndex:i]];
                }
                
                    //漲跌幅
                if(mySnapshot.currentPrice != 0 && mySnapshot.referencePrice !=0){
                    double p_chg = (mySnapshot.currentPrice - mySnapshot.referencePrice)/mySnapshot.referencePrice*10000;
                    if (p_chg>0) {
                        p_chg = floor(p_chg);
                    }else if (p_chg<0) {
                        p_chg = ceil(p_chg);
                    }
                    p_chg = p_chg/100;
                    
                    [p_chgDictionary setObject:[NSString stringWithFormat:@"%.2lf%%",p_chg] forKey:[rowArray objectAtIndex:i]];   
                    
                }else{
                    [p_chgDictionary setObject:@"----" forKey:[rowArray objectAtIndex:i]];
                }
                
                    //單量
                int volume = mySnapshot.volume;
                if(volume == 0){
                    [VolumeDictionary setObject:@"----" forKey:[rowArray objectAtIndex:i]];
                }else{
                    [VolumeDictionary setObject:[NSString stringWithFormat:@"%d",volume] forKey:[rowArray objectAtIndex:i]];
                }

                
                //總量
                int accumulatedVolumeUnit = mySnapshot.accumulatedVolumeUnit;
                double accumulatedVolume = mySnapshot.accumulatedVolume  * (pow(1000, accumulatedVolumeUnit));
                
                if (accumulatedVolume != 0)
                {
                    [accumulatedVolumeDictionary setObject:[CodingUtil stringWithVolumeByValue:accumulatedVolume] forKey:[rowArray objectAtIndex:i]];
                }else{
                    [accumulatedVolumeDictionary setObject:@"----" forKey:[rowArray objectAtIndex:i]];
                }
                
            }
        }

    }
    
    NSMutableArray * priceArray =[[NSMutableArray alloc]initWithObjects:bidPriceDictionary,askPriceDictionary,currentPriceDictionary,highestPriceDictionary,lowestPriceDictionary,chgDictionary,p_chgDictionary,VolumeDictionary,accumulatedVolumeDictionary,referencePriceDictionary,statusDictionary,topPriceDictionary,bottomPriceDictionary, nil];
    
    [notifyObj performSelectorOnMainThread:@selector(SnapshotNnotifyDataArrive:) withObject:priceArray waitUntilDone:NO];
    
}

-(void)searchData:(NSNumber *)number{   //???資料有待確認
    NSMutableArray * nameArray = [[NSMutableArray alloc]init];
    NSMutableArray * idArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        FMResultSet *message = [db executeQuery:@"SELECT CatName,CatID FROM category WHERE parentID = ? ORDER BY CatID",number];
        while ([message next]) {
            [nameArray addObject:[message stringForColumn:@"CatName"]];
            [idArray addObject:[message stringForColumn:@"CatID"]];
        }
    }];
    NSMutableArray * dataArray = [[NSMutableArray alloc]initWithObjects:nameArray,idArray, nil];
    
    [groupNotifyObj performSelectorOnMainThread:@selector(groupNotifyDataArrive:) withObject:dataArray waitUntilDone:NO];
}
@end
