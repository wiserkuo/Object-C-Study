//
//  BoardMemberTransfer.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "BoardMemberTransfer.h"
#import "BoardMemberTransferOut.h"
#import "FSInstantInfoWatchedPortfolio.h"

@interface BoardMemberTransfer()
@property (nonatomic, strong) NSRecursiveLock *datalock;
@property (nonatomic, strong) NSMutableDictionary *mainDict;
@property (nonatomic, strong) PortfolioItem *portfolioItem;
@end


@implementation BoardMemberTransfer
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
                      [NSString stringWithFormat:@"%c%c %@ BoardMemberTransfer.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    
    if ([[self.mainDict objectForKey:@"Date"] isEqualToString:dateStr]) {
        if ([self.delegate respondsToSelector:@selector(notifyBoardMemberTransferData:)]) {
            [self.delegate performSelectorOnMainThread:@selector(notifyBoardMemberTransferData:) withObject:self.mainDict waitUntilDone:NO];
        }
    } else {
        self.mainDict = [[NSMutableDictionary alloc] init];
        PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
        UInt16 tmpDate;
        tmpDate = [CodingUtil makeDate:1960 month:1 day:1];
        BoardMemberTransferOut *cpOut = [[BoardMemberTransferOut alloc] initWithSecurityNum:portfolioItem->commodityNo Top_n:0 start:0 end:0 modified:tmpDate];
        [FSDataModelProc sendData:self WithPacket:cpOut];
    }
    [self.datalock unlock];
}

-(void)BoardMemberTransferDataCallBack:(BoardMemberTransferIn *)data
{
    [self.datalock lock];
    NSMutableArray *transferDate = [[NSMutableArray alloc] init];
    NSMutableArray *holderNameArray = [[NSMutableArray alloc] init];
    NSMutableArray *holderTitleArray = [[NSMutableArray alloc] init];
    NSMutableArray *applyShareArray = [[NSMutableArray alloc] init];
    NSMutableArray *applyPriceArray = [[NSMutableArray alloc] init];
    NSMutableArray *orgShareArray = [[NSMutableArray alloc] init];
    NSMutableArray *actualTransferArray = [[NSMutableArray alloc] init];
    NSMutableArray *methodArray = [[NSMutableArray alloc] init];
    for(int i = 0 ; i<[data->holdDataArray count]; i++){
        BoardMemberTransferObject *object = [data->holdDataArray objectAtIndex:i];
        if(object){
            [transferDate addObject:[CodingUtil getStringDate:object->dataDate]];
            if(object->holderName != nil){
                [holderNameArray addObject:object->holderName];
                
            }
            if(object->holderTitle != nil){
                [holderTitleArray addObject:object->holderTitle];
            }
            [applyShareArray addObject:[NSNumber numberWithDouble:object->applyShare]];
            [applyPriceArray addObject:[NSNumber numberWithDouble:object->applyPrice]];
            [orgShareArray addObject:[NSNumber numberWithDouble:object->orgShare]];
            [actualTransferArray addObject:[NSNumber numberWithDouble:object->actualTransfer]];
            if(object->transferMethod != nil){
                [methodArray addObject:object->transferMethod];
            }
        }
    }
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    [self.mainDict setObject:[NSNumber numberWithUnsignedInteger:[data->holdDataArray count]] forKey:@"BoardMemberTransferCount"];
    [self.mainDict setObject:dateStr forKey:@"Date"];
    [self.mainDict setObject:transferDate forKey:@"TransferDate"];
    [self.mainDict setObject:holderNameArray forKey:@"HolderName"];
    [self.mainDict setObject:holderTitleArray forKey:@"HolderTitle"];
    [self.mainDict setObject:applyShareArray forKey:@"ApplyShare"];
    [self.mainDict setObject:applyPriceArray forKey:@"ApplyPrice"];
    [self.mainDict setObject:orgShareArray forKey:@"OrgShare"];
    [self.mainDict setObject:actualTransferArray forKey:@"ActualTransfer"];
    [self.mainDict setObject:methodArray forKey:@"Method"];
    
    [self saveToFile];
    
    if([self.delegate respondsToSelector:@selector(notifyBoardMemberTransferData:)]){
        [self.delegate notifyBoardMemberTransferData:self.mainDict];
    }
    
    [self.datalock unlock];
    
}

- (void)saveToFile {
	[self.datalock lock];
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%c%c %@ BoardMemberTransfer.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
	BOOL success = [self.mainDict writeToFile:path atomically:YES];
	if(!success) NSLog(@"companyProfile wirte error!!");
	[self.datalock unlock];
}
@end
