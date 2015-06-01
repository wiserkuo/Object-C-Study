//
//  FigureSearchUS.m
//  WirtsLeg
//
//  Created by Connor on 13/11/21.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FigureSearchUS.h"
#import "FigureSearchUSIn.h"
#import "FigureSearchUSOut.h"

#define SECTOR_DIAN_TOU      2     // 店頭市場
#define SECTOR_JI_JHONG     21     // 集中市場
#define SECTOR_SHANG_JIAO   101    //上交所
#define SECTOR_SHEN_JIAO    121    //深交所
#define SECTOR_NYSE         296     //NYSE
#define SECTOR_NASDAQ       297     //NASDAQ
#define SECTOR_AMEX         298     //AMEX

@interface FigureSearchUS() {
    NSRecursiveLock *dataLock;
}
@property (strong, nonatomic) NSArray *sectorIDsArray;
@property (unsafe_unretained, nonatomic) UInt8 sn;
@property (unsafe_unretained, nonatomic) UInt16 totalAmount;
@property (unsafe_unretained, nonatomic) UInt16 dataDate;
@property (unsafe_unretained, nonatomic) UInt8 dataAmount;
@property (unsafe_unretained, nonatomic) BOOL moreData;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableArray *markPriceArray;
@end

@implementation FigureSearchUS

- (id)init {
    if (self = [super init]) {
        dataLock = [[NSRecursiveLock alloc] init];
        self.dataArray = [[NSMutableArray alloc] init];
        self.markPriceArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)searchByType:(enum FigureSearchUSFeeType)type
           sectorIDs:(NSArray *)sectorIDsArray
                flag:(UInt8)flag
                  sn:(UInt8)sn
            reqCount:(UInt8)reqCount
      equationString:(NSString *)equationString {
    
    [dataLock lock];
    
    self.sectorIDsArray = sectorIDsArray;
    
    UInt8 sectorIDsCount = [sectorIDsArray count];
    UInt16 equationLen = [equationString length];
    
    UInt16 *sectorID = malloc(sectorIDsCount * sizeof(UInt16));
    
    for (int i = 0; i < sectorIDsCount; i++) {
        sectorID[i] = [[sectorIDsArray objectAtIndex:i] unsignedIntValue];
    }
    
    UInt8 *equation = malloc(equationLen * sizeof(UInt8));
    
    for (int i = 0; i < equationLen; i++) {
        equation[i] = [equationString characterAtIndex:i];
    }
    
    FigureSearchUSOut *figureSearchUSOut = [[FigureSearchUSOut alloc] initWithFigureSearchUSFeeType:type SectorIDs:sectorID sectorIDsCount:sectorIDsCount flag:flag sn:sn reqCount:reqCount equationLen:equationLen equationString:equation];
    
    [FSDataModelProc sendData:self WithPacket:figureSearchUSOut];
    
    free(sectorID);
    free(equation);
    
    [dataLock unlock];
}

- (void)callBackData:(FigureSearchUSIn *)data {
    [dataLock lock];
    
    self.sn = data->sn;
    self.dataAmount += data->dataAmount;
    self.dataDate = data->dataDate;
    self.totalAmount = data->totalAmount;
    [self.dataArray addObjectsFromArray:data->dataArray];
    [self.markPriceArray addObjectsFromArray:data->markPriceArray];

    if (data->moreData) {
        [dataLock unlock];
        return;
    }
    
    NSMutableString *marketString = [[NSMutableString alloc] init];
    
    // TODO: 偷懶做法, 未來需要加上所有的mapping表
    for (NSNumber *sectorID in self.sectorIDsArray) {
        
        // 台股
        if ([sectorID isEqualToNumber:@SECTOR_DIAN_TOU]) {
            [marketString appendString:@"店頭市場,"];
        } else if ([sectorID isEqualToNumber:@SECTOR_JI_JHONG]) {
            [marketString appendString:@"集中市場,"];
        }
        
        //美股
        if ([sectorID isEqualToNumber:@SECTOR_NYSE]) {
            [marketString appendString:@"NYSE,"];
        } else if ([sectorID isEqualToNumber:@SECTOR_NASDAQ]) {
            [marketString appendString:@"NASDAQ,"];
        } else if ([sectorID isEqualToNumber:@SECTOR_AMEX]) {
            [marketString appendString:@"AMEX,"];
        }

        //陸股
        if ([sectorID isEqualToNumber:@SECTOR_SHANG_JIAO]) {
            [marketString appendString:@"上交所,"];
        } else if ([sectorID isEqualToNumber:@SECTOR_SHEN_JIAO]) {
            [marketString appendString:@"深交所,"];
        }
        
        if ([sectorID isEqualToNumber:[self.sectorIDsArray lastObject]]) {
            [marketString substringToIndex:[marketString length] - 1];
            [marketString deleteCharactersInRange:NSMakeRange([marketString length] - 1, 1)];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(callBackResultEquationName:targetMarket:dataAmount:totalAmount:dataDate:dataArray:markPriceArray:)]) {
        [self.delegate callBackResultEquationName:@"" targetMarket:marketString dataAmount:self.dataAmount totalAmount:self.totalAmount dataDate:self.dataDate dataArray:self.dataArray markPriceArray:self.markPriceArray];
    }
    
    if (!data->moreData) {
        self.dataAmount = 0;
        self.totalAmount = 0;
        [self.dataArray removeAllObjects];
        [self.markPriceArray removeAllObjects];
    }
    
    [dataLock unlock];
}


@end
