//
//  MajorProducts.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "MajorProducts.h"
#import "MajorProductsOut.h"
#import "FSInstantInfoWatchedPortfolio.h"
@interface MajorProducts()
@property (nonatomic, strong) NSRecursiveLock *datalock;
@property (nonatomic, strong) NSMutableDictionary *mainDict;
@property (nonatomic, strong) PortfolioItem *portfolioItem;
@end



@implementation MajorProducts
- (instancetype)init {
    if (self = [super init]) {
        self.datalock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

- (void)sendAndRead {
    [self.datalock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:30]];
    
    self.portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%c%c %@ MajorProducts.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    
    
    if ([[self.mainDict objectForKey:@"Date"] isEqualToString:dateStr]) {
        if ([self.delegate respondsToSelector:@selector(notifyProductData:)]) {
            [self.delegate performSelectorOnMainThread:@selector(notifyProductData:) withObject:self.mainDict waitUntilDone:NO];
        }
    } else {
        self.mainDict = [[NSMutableDictionary alloc] init];
        PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
        UInt16 tmpDate;
        tmpDate = [CodingUtil makeDate:1960 month:1 day:1];
        MajorProductsOut *cpOut = [[MajorProductsOut alloc] initWithSecurityNum:portfolioItem->commodityNo
                                                                        count:5 recordDate:tmpDate];
        [FSDataModelProc sendData:self WithPacket:cpOut];
    }
    [self.datalock unlock];
}

-(void)MajorProductsDataCallBack:(MajorProductsIn *)data
{
    [self.datalock lock];
    NSMutableArray *productArray = [[NSMutableArray alloc] init];
    NSMutableArray *revRateArray = [[NSMutableArray alloc] init];
    for(int i = 0 ; i<[data->dataArray count]; i++){
        MajorProductsObject *object = [data->dataArray objectAtIndex:i];
        if(object){
            [productArray addObject:object->productName];
            [revRateArray addObject:[NSNumber numberWithDouble:object->revRate]];
        }
    }
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    [self.mainDict setObject:dateStr forKey:@"Date"];
    [self.mainDict setObject:[NSNumber numberWithInteger:[data->dataArray count]] forKey:@"MajorProductsCount"];
    [self.mainDict setObject:productArray forKey:@"ProductName"];
    [self.mainDict setObject:revRateArray forKey:@"RevRate"];
    
    [self saveToFile];
    
    if([self.delegate respondsToSelector:@selector(notifyProductData:)]){
        [self.delegate notifyProductData:self.mainDict];
    }
    
    [self.datalock unlock];
    
}

- (void)saveToFile {
	[self.datalock lock];
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%c%c %@ MajorProducts.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
	BOOL success = [self.mainDict writeToFile:path atomically:YES];
	if(!success) NSLog(@"companyProfile wirte error!!");
	[self.datalock unlock];
}

@end
